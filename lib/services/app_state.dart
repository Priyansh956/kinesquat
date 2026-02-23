import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';
import 'squat_detector.dart';

class AppState extends ChangeNotifier {
  final StorageService storage;

  AppState(this.storage) {
    // Sync detector threshold from saved prefs
    _detector.setBreakThresholdMs = storage.restThresholdMs;
    _initPedometer();
  }

  // ════════════════════════════════════════════════════════
  //  LIVE TRACKING STATE
  // ════════════════════════════════════════════════════════
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  int _currentSetReps = 0;
  int get currentSetReps => _currentSetReps;

  int _liveSets = 0;
  int get liveSets => _liveSets;

  int _liveReps = 0;
  int get liveReps => _liveReps;

  DateTime? _lastRepTime;
  DateTime? get lastRepTime => _lastRepTime;

  int _msSinceLastRep = 0;
  int get msSinceLastRep => _msSinceLastRep;

  Timer? _breakTimer;

  // ── Weight for current session ─────────────────────────
  /// Extra weight added (barbell, vest, etc.) in kg
  double _addedWeightKg = 0;
  double get addedWeightKg => _addedWeightKg;

  void setAddedWeight(double kg) {
    _addedWeightKg = kg;
    notifyListeners();
  }

  double get totalSessionWeightKg => storage.bodyWeightKg + _addedWeightKg;

  /// Estimated kcal for the current live session
  double get liveSessionKcal {
    if (_liveReps == 0) return 0;
    final met = 5.0 + (_addedWeightKg * 0.02).clamp(0, 3);
    final durationHours = (_liveReps * 3) / 3600;
    return met * storage.bodyWeightKg * durationHours;
  }

  // ════════════════════════════════════════════════════════
  //  DATE SELECTION (for Activities screen)
  // ════════════════════════════════════════════════════════
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  bool get isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  void selectDate(DateTime d) {
    _selectedDate = d;
    notifyListeners();
  }

  List<SquatSession> get sessionsForSelectedDate =>
      storage.getSessionsForDate(_selectedDate);

  int get selectedDateReps =>
      sessionsForSelectedDate.fold(0, (s, e) => s + e.reps) +
          (isSelectedDateToday && isTracking ? _liveReps : 0);

  int get selectedDateSets =>
      sessionsForSelectedDate.fold(0, (s, e) => s + e.sets) +
          (isSelectedDateToday && isTracking ? _liveSets : 0);

  double get selectedDateKcal =>
      sessionsForSelectedDate.fold(0.0, (s, e) => s + e.estimatedKcal) +
          (isSelectedDateToday && isTracking ? liveSessionKcal : 0);

  // ════════════════════════════════════════════════════════
  //  FILTER (Tracking screen history tabs)
  // ════════════════════════════════════════════════════════
  String _filter = 'All';
  String get filter => _filter;

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════
  //  AGGREGATE STATS
  // ════════════════════════════════════════════════════════
  int get totalSets {
    final hist = storage.getFilteredSessions(_filter).fold(0, (s, e) => s + e.sets);
    return isTracking ? hist + _liveSets : hist;
  }

  int get totalReps {
    final hist = storage.getFilteredSessions(_filter).fold(0, (s, e) => s + e.reps);
    return isTracking ? hist + _liveReps : hist;
  }

  int get todaySets {
    final hist = storage.getSessionsForDate(DateTime.now()).fold(0, (s, e) => s + e.sets);
    return isTracking ? hist + _liveSets : hist;
  }

  int get todayReps {
    final hist = storage.getSessionsForDate(DateTime.now()).fold(0, (s, e) => s + e.reps);
    return isTracking ? hist + _liveReps : hist;
  }

  double get progress => storage.getTodayProgress(
      isTracking ? _liveReps : 0, isTracking ? _liveSets : 0);

  Map<String, int> get weeklySquats => storage.getWeeklySquatCounts(
    anchor: _selectedDate,
    extraRepsToday: isTracking ? _liveReps : 0,
  );

  // ════════════════════════════════════════════════════════
  //  PEDOMETER
  // ════════════════════════════════════════════════════════
  int _steps = 0;
  int get steps => _steps;

  // Steps for the selected date (today uses live pedometer, past dates use stored)
  int get selectedDateSteps {
    if (isSelectedDateToday) return _steps;
    return storage.getStepsForDate(_selectedDate);
  }
  double get kcal => storage.getKCalFromSteps(_steps);

  String _pedometerStatus = 'initializing';
  String get pedometerStatus => _pedometerStatus;

  StreamSubscription<StepCount>? _stepSub;

  Future<void> _initPedometer() async {
    _steps = storage.getTodaySteps();
    notifyListeners();
    final status = await Permission.activityRecognition.request();
    if (!status.isGranted) {
      _pedometerStatus = 'denied';
      notifyListeners();
      return;
    }
    _stepSub = Pedometer.stepCountStream.listen(
          (e) {
        _steps = e.steps;
        _pedometerStatus = 'active';
        storage.saveSteps(_steps);
        notifyListeners();
      },
      onError: (_) {
        _pedometerStatus = 'unavailable';
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  // ════════════════════════════════════════════════════════
  //  SQUAT DETECTOR
  // ════════════════════════════════════════════════════════
  late final SquatDetectorService _detector = SquatDetectorService(
    onRep: _onRepDetected,
    onSetBreak: _onSetBreak,
    setBreakThresholdMs: storage.restThresholdMs,
  );

  void _onRepDetected() {
    _liveReps++;
    _currentSetReps++;
    _lastRepTime = DateTime.now();
    _msSinceLastRep = 0;
    notifyListeners();
  }

  void _onSetBreak() {
    if (_currentSetReps > 0) {
      _liveSets++;
      _currentSetReps = 0;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════
  //  START / STOP
  // ════════════════════════════════════════════════════════
  void startTracking() {
    _liveSets = 0;
    _liveReps = 0;
    _currentSetReps = 0;
    _lastRepTime = null;
    _msSinceLastRep = 0;
    _isTracking = true;
    // Sync threshold in case user changed it
    _detector.setBreakThresholdMs = storage.restThresholdMs;
    _detector.start();

    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_lastRepTime != null) {
        _msSinceLastRep =
            DateTime.now().difference(_lastRepTime!).inMilliseconds;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> stopTracking() async {
    _detector.stop();
    _breakTimer?.cancel();
    if (_currentSetReps > 0) _liveSets++;

    if (_liveReps > 0) {
      await storage.saveSession(SquatSession(
        date: DateTime.now(),
        sets: _liveSets,
        reps: _liveReps,
        exercise: 'Legs',
        addedWeightKg: _addedWeightKg,
        bodyWeightKg: storage.bodyWeightKg,
      ));
    }

    _isTracking = false;
    _liveSets = 0;
    _liveReps = 0;
    _currentSetReps = 0;
    _lastRepTime = null;
    _msSinceLastRep = 0;
    _addedWeightKg = 0;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════
  //  MANUAL OVERRIDES
  // ════════════════════════════════════════════════════════
  void manualIncrementRep() => _onRepDetected();

  void manualIncrementSet() {
    _liveSets++;
    _currentSetReps = 0;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════
  //  GOALS & SETTINGS
  // ════════════════════════════════════════════════════════
  int get repGoal => storage.repGoal;
  int get setGoal => storage.setGoal;
  double get bodyWeightKg => storage.bodyWeightKg;
  int get restThresholdMs => storage.restThresholdMs;

  Future<void> updateRepGoal(int v) async {
    await storage.setRepGoal(v);
    notifyListeners();
  }

  Future<void> updateSetGoal(int v) async {
    await storage.setSetGoal(v);
    notifyListeners();
  }

  Future<void> updateBodyWeight(double v) async {
    await storage.setBodyWeightKg(v);
    notifyListeners();
  }

  Future<void> updateRestThreshold(int ms) async {
    await storage.setRestThresholdMs(ms);
    _detector.setBreakThresholdMs = ms;
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await storage.clearSessions();
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════
  //  DISPOSE
  // ════════════════════════════════════════════════════════
  @override
  void dispose() {
    _detector.stop();
    _stepSub?.cancel();
    _breakTimer?.cancel();
    super.dispose();
  }
}