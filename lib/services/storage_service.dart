import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SquatSession {
  final DateTime date;
  final int sets;
  final int reps;
  final String exercise;

  SquatSession({
    required this.date,
    required this.sets,
    required this.reps,
    required this.exercise,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'sets': sets,
    'reps': reps,
    'exercise': exercise,
  };

  factory SquatSession.fromJson(Map<String, dynamic> json) => SquatSession(
    date: DateTime.parse(json['date']),
    sets: json['sets'],
    reps: json['reps'],
    exercise: json['exercise'],
  );
}

class StorageService {
  final SharedPreferences _prefs;

  static const _sessionsKey = 'squat_sessions';
  static const _repGoalKey = 'rep_goal';
  static const _setGoalKey = 'set_goal';
  static const _stepsKey = 'daily_steps';
  static const _currentSetsKey = 'current_sets';
  static const _currentRepsKey = 'current_reps';

  StorageService(this._prefs);

  // ── Goals ──────────────────────────────────────────────
  int get repGoal => _prefs.getInt(_repGoalKey) ?? 10;
  int get setGoal => _prefs.getInt(_setGoalKey) ?? 3;

  Future<void> setRepGoal(int value) => _prefs.setInt(_repGoalKey, value);
  Future<void> setSetGoal(int value) => _prefs.setInt(_setGoalKey, value);

  // ── Current session live counters ──────────────────────
  int get currentSets => _prefs.getInt(_currentSetsKey) ?? 0;
  int get currentReps => _prefs.getInt(_currentRepsKey) ?? 0;

  Future<void> setCurrentSets(int v) => _prefs.setInt(_currentSetsKey, v);
  Future<void> setCurrentReps(int v) => _prefs.setInt(_currentRepsKey, v);

  // ── Sessions ───────────────────────────────────────────
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
    await _prefs.remove(_currentSetsKey);
    await _prefs.remove(_currentRepsKey);
  }

  // ── Filtered sessions ──────────────────────────────────
  List<SquatSession> getFilteredSessions(String filter) {
    final all = getSessions();
    final now = DateTime.now();
    switch (filter) {
      case 'Today':
        return all
            .where((s) =>
        s.date.year == now.year &&
            s.date.month == now.month &&
            s.date.day == now.day)
            .toList();
      case 'Weekly':
        final weekAgo = now.subtract(const Duration(days: 7));
        return all.where((s) => s.date.isAfter(weekAgo)).toList();
      case 'Monthly':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return all.where((s) => s.date.isAfter(monthAgo)).toList();
      case 'Yearly':
        final yearAgo = DateTime(now.year - 1, now.month, now.day);
        return all.where((s) => s.date.isAfter(yearAgo)).toList();
      default:
        return all;
    }
  }

  // ── Progress (0.0 - 1.0) ──────────────────────────────
  double getTodayProgress() {
    final today = getFilteredSessions('Today');
    if (today.isEmpty) return 0.0;
    final totalReps = today.fold(0, (sum, s) => sum + s.reps);
    final totalSets = today.fold(0, (sum, s) => sum + s.sets);
    final repProgress = totalReps / (repGoal * setGoal).clamp(1, 999);
    final setProgress = totalSets / setGoal.clamp(1, 999);
    return ((repProgress + setProgress) / 2).clamp(0.0, 1.0);
  }

  // ── Weekly squat counts for bar chart ─────────────────
  Map<String, int> getWeeklySquatCounts() {
    final all = getSessions();
    final now = DateTime.now();
    final Map<String, int> result = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (final session in all) {
      final diff = now.difference(session.date).inDays;
      if (diff < 7) {
        // weekday: 1=Mon ... 7=Sun
        final dayName = days[session.date.weekday - 1];
        result[dayName] = (result[dayName] ?? 0) + session.reps;
      }
    }
    return result;
  }

  // ── Steps ──────────────────────────────────────────────
  Future<void> saveSteps(int steps) async {
    final key = '${_stepsKey}_${_todayKey()}';
    await _prefs.setInt(key, steps);
  }

  int getTodaySteps() {
    return _prefs.getInt('${_stepsKey}_${_todayKey()}') ?? 0;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }

  // ── kCal from steps (rough estimate: 0.04 kcal/step) ──
  double getKCalFromSteps(int steps) {
    return steps * 0.04;
  }

  // ── Import / Export ────────────────────────────────────
  String exportData() {
    final sessions = getSessions();
    return jsonEncode(sessions.map((s) => s.toJson()).toList());
  }

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