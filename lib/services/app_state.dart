import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';
import 'squat_detector.dart';

class AppState extends ChangeNotifier {
  final StorageService storage;

  AppState(this.storage) {
    _initPedometer();
  }

  // ════════════════════════════════════════════════════════
  //  LIVE TRACKING STATE
  // ════════════════════════════════════════════════════════
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  /// Reps in the current set (resets on set break)
  int _currentSetReps = 0;
  int get currentSetReps => _currentSetReps;

  /// Completed sets in this session
  int _liveSets = 0;
  int get liveSets => _liveSets;

  /// Total reps across all sets in this session
  int _liveReps = 0;
  int get liveReps => _liveReps;

  DateTime? _lastRepTime;
  DateTime? get lastRepTime => _lastRepTime;

  int _msSinceLastRep = 0;
  int get msSinceLastRep => _msSinceLastRep;

  Timer? _breakTimer;

  // ════════════════════════════════════════════════════════
  //  FILTER
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
    final s = storage.getFilteredSessions(_filter);
    final hist = s.fold(0, (sum, e) => sum + e.sets);
    return isTracking ? hist + _liveSets : hist;
  }

  int get totalReps {
    final s = storage.getFilteredSessions(_filter);
    final hist = s.fold(0, (sum, e) => sum + e.reps);
    return isTracking ? hist + _liveReps : hist;
  }

  int get todaySets {
    final s = storage.getFilteredSessions('Today');
    final hist = s.fold(0, (sum, e) => sum + e.sets);
    return isTracking ? hist + _liveSets : hist;
  }

  int get todayReps {
    final s = storage.getFilteredSessions('Today');
    final hist = s.fold(0, (sum, e) => sum + e.reps);
    return isTracking ? hist + _liveReps : hist;
  }

  double get progress {
    final goal = (storage.repGoal * storage.setGoal).clamp(1, 9999);
    final sGoal = storage.setGoal.clamp(1, 9999);
    final rProg = todayReps / goal;
    final sProg = todaySets / sGoal;
    return ((rProg + sProg) / 2).clamp(0.0, 1.0);
  }

  Map<String, int> get weeklySquats => storage.getWeeklySquatCounts();

  // ════════════════════════════════════════════════════════
  //  PEDOMETER
  // ════════════════════════════════════════════════════════
  int _steps = 0;
  int get steps => _steps;
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
    setBreakThresholdMs: 8000, // 8-second rest → new set
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
      ));
    }

    _isTracking = false;
    _liveSets = 0;
    _liveReps = 0;
    _currentSetReps = 0;
    _lastRepTime = null;
    _msSinceLastRep = 0;

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
  //  GOALS
  // ════════════════════════════════════════════════════════
  int get repGoal => storage.repGoal;
  int get setGoal => storage.setGoal;

  Future<void> updateRepGoal(int v) async {
    await storage.setRepGoal(v);
    notifyListeners();
  }

  Future<void> updateSetGoal(int v) async {
    await storage.setSetGoal(v);
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