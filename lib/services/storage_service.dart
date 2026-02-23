import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════════════════
//  DATA MODEL
// ══════════════════════════════════════════════════════════════
class SquatSession {
  final DateTime date;
  final int sets;
  final int reps;
  final String exercise;
  /// Extra barbell/dumbbell weight added (kg). 0 = bodyweight only.
  final double addedWeightKg;
  /// User's body weight at time of session (kg).
  final double bodyWeightKg;

  SquatSession({
    required this.date,
    required this.sets,
    required this.reps,
    required this.exercise,
    this.addedWeightKg = 0,
    this.bodyWeightKg = 70,
  });

  /// Total load moved per rep (kg)
  double get totalWeightKg => bodyWeightKg + addedWeightKg;

  /// Estimated calories burned using MET formula.
  /// MET for weighted squats ≈ 5 + 0.02 per extra kg (rough heuristic)
  /// kcal = MET × bodyWeight(kg) × duration(h)
  /// We estimate duration as reps × 3 seconds per rep.
  double get estimatedKcal {
    final met = 5.0 + (addedWeightKg * 0.02).clamp(0, 3);
    final durationHours = (reps * 3) / 3600;
    return met * bodyWeightKg * durationHours;
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'sets': sets,
    'reps': reps,
    'exercise': exercise,
    'addedWeightKg': addedWeightKg,
    'bodyWeightKg': bodyWeightKg,
  };

  factory SquatSession.fromJson(Map<String, dynamic> json) => SquatSession(
    date: DateTime.parse(json['date']),
    sets: json['sets'],
    reps: json['reps'],
    exercise: json['exercise'],
    addedWeightKg: (json['addedWeightKg'] as num?)?.toDouble() ?? 0,
    bodyWeightKg: (json['bodyWeightKg'] as num?)?.toDouble() ?? 70,
  );
}

// ══════════════════════════════════════════════════════════════
//  STORAGE SERVICE
// ══════════════════════════════════════════════════════════════
class StorageService {
  final SharedPreferences _prefs;

  static const _sessionsKey      = 'squat_sessions';
  static const _repGoalKey       = 'rep_goal';
  static const _setGoalKey       = 'set_goal';
  static const _stepsKey         = 'daily_steps';
  static const _bodyWeightKey    = 'body_weight_kg';
  static const _restThresholdKey = 'rest_threshold_ms';

  StorageService(this._prefs);

  // ── Goals ─────────────────────────────────────────────────
  int get repGoal => _prefs.getInt(_repGoalKey) ?? 10;
  int get setGoal => _prefs.getInt(_setGoalKey) ?? 3;
  Future<void> setRepGoal(int v) => _prefs.setInt(_repGoalKey, v);
  Future<void> setSetGoal(int v) => _prefs.setInt(_setGoalKey, v);

  // ── Body weight ────────────────────────────────────────────
  double get bodyWeightKg =>
      (_prefs.getDouble(_bodyWeightKey) ?? 70.0);
  Future<void> setBodyWeightKg(double v) =>
      _prefs.setDouble(_bodyWeightKey, v);

  // ── Rest threshold ─────────────────────────────────────────
  /// In milliseconds. Default 5 000 ms (5 s).
  int get restThresholdMs =>
      _prefs.getInt(_restThresholdKey) ?? 5000;
  Future<void> setRestThresholdMs(int v) =>
      _prefs.setInt(_restThresholdKey, v);

  // ── Sessions ───────────────────────────────────────────────
  List<SquatSession> getSessions() {
    final raw = _prefs.getStringList(_sessionsKey) ?? [];
    return raw
        .map((s) => SquatSession.fromJson(jsonDecode(s)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveSession(SquatSession session) async {
    final sessions = getSessions();
    sessions.add(session);
    final raw = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs.setStringList(_sessionsKey, raw);
  }

  Future<void> clearSessions() async {
    await _prefs.remove(_sessionsKey);
  }

  // ── Filtered sessions ──────────────────────────────────────
  List<SquatSession> getFilteredSessions(String filter) {
    final all = getSessions();
    final now = DateTime.now();
    switch (filter) {
      case 'Today':
        return _forDate(all, now);
      case 'Weekly':
        final ago = now.subtract(const Duration(days: 7));
        return all.where((s) => s.date.isAfter(ago)).toList();
      case 'Monthly':
        final ago = DateTime(now.year, now.month - 1, now.day);
        return all.where((s) => s.date.isAfter(ago)).toList();
      case 'Yearly':
        final ago = DateTime(now.year - 1, now.month, now.day);
        return all.where((s) => s.date.isAfter(ago)).toList();
      default:
        return all;
    }
  }

  /// Sessions for a specific calendar date.
  List<SquatSession> getSessionsForDate(DateTime date) =>
      _forDate(getSessions(), date);

  List<SquatSession> _forDate(List<SquatSession> all, DateTime d) =>
      all
          .where((s) =>
      s.date.year == d.year &&
          s.date.month == d.month &&
          s.date.day == d.day)
          .toList();

  // ── Progress ───────────────────────────────────────────────
  double getTodayProgress(int extraReps, int extraSets) {
    final today = getSessionsForDate(DateTime.now());
    final totalReps =
        today.fold(0, (s, e) => s + e.reps) + extraReps;
    final totalSets =
        today.fold(0, (s, e) => s + e.sets) + extraSets;
    final rProg = totalReps / (repGoal * setGoal).clamp(1, 9999);
    final sProg = totalSets / setGoal.clamp(1, 9999);
    return ((rProg + sProg) / 2).clamp(0.0, 1.0);
  }

  // ── Weekly squat counts for the week containing [anchor] ───
  Map<String, int> getWeeklySquatCounts({
    DateTime? anchor,
    int extraRepsToday = 0,
  }) {
    final all = getSessions();
    final ref = anchor ?? DateTime.now();
    // Monday of the week containing ref
    final monday = ref.subtract(Duration(days: ref.weekday - 1));
    final mondayDate = DateTime(monday.year, monday.month, monday.day);

    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = {for (var l in labels) l: 0};

    for (final s in all) {
      final diff = s.date.difference(mondayDate).inDays;
      if (diff >= 0 && diff < 7) {
        final label = labels[diff];
        result[label] = result[label]! + s.reps;
      }
    }

    // Add live reps to today's slot only if today falls in this week
    if (extraRepsToday > 0) {
      final today = DateTime.now();
      final todayDiff = today.difference(mondayDate).inDays;
      if (todayDiff >= 0 && todayDiff < 7) {
        final todayLabel = labels[today.weekday - 1];
        result[todayLabel] = result[todayLabel]! + extraRepsToday;
      }
    }

    return result;
  }

  // ── Steps ──────────────────────────────────────────────────
  Future<void> saveSteps(int steps) async {
    await _prefs.setInt('${_stepsKey}_${_todayKey()}', steps);
  }

  int getTodaySteps() =>
      _prefs.getInt('${_stepsKey}_${_todayKey()}') ?? 0;

  int getStepsForDate(DateTime d) =>
      _prefs.getInt('${_stepsKey}_${d.year}_${d.month}_${d.day}') ?? 0;

  String _todayKey() {
    final n = DateTime.now();
    return '${n.year}_${n.month}_${n.day}';
  }

  // ── kCal from steps ────────────────────────────────────────
  double getKCalFromSteps(int steps) => steps * 0.04;

  // ── Import / Export ────────────────────────────────────────
  String exportData() =>
      jsonEncode(getSessions().map((s) => s.toJson()).toList());

  Future<bool> importData(String jsonStr) async {
    try {
      final list = jsonDecode(jsonStr) as List;
      final sessions = list.map((e) => SquatSession.fromJson(e)).toList();
      final raw = sessions.map((s) => jsonEncode(s.toJson())).toList();
      await _prefs.setStringList(_sessionsKey, raw);
      return true;
    } catch (_) {
      return false;
    }
  }
}