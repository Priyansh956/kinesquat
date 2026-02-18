import 'dart:async';
import 'dart:math';
import 'package:flutter/animation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Fires [onRep] whenever a squat rep is confidently detected.
/// Fires [onSetBreak] whenever inter-rep gap exceeds [setBreakThreshold].
///
/// Algorithm (vertical-axis accelerometer):
///   1. Smooth raw Y-axis with an exponential low-pass filter.
///   2. Detect a DOWN phase when smoothed Y drops below [descendThreshold].
///   3. Detect an UP phase when smoothed Y rises above [ascendThreshold]
///      *after* a down phase has been committed.
///   4. One full DOWN→UP cycle = 1 rep.
///   5. If the gap between the last rep and now > [setBreakThreshold],
///      the next rep belongs to a new set.
class SquatDetectorService {
  // ── Public callbacks ───────────────────────────────────
  final VoidCallback onRep;
  final VoidCallback onSetBreak;

  // ── Tunable constants ──────────────────────────────────
  /// Low-pass smoothing factor (0 = full smoothing, 1 = raw). 0.15 works well.
  static const double _alpha = 0.15;

  /// Smoothed magnitude below this → user is squatting down (gravity reduces).
  static const double _descendThreshold = 8.8; // m/s²

  /// Smoothed magnitude above this → user has returned up.
  static const double _ascendThreshold = 9.6; // m/s²

  /// Minimum time a down-phase must last to count as intentional (ms).
  static const int _minDownMs = 200;

  /// Minimum ms between two rep detections (debounce).
  static const int _repDebounceMs = 800;

  /// Gap between reps longer than this → new set (ms).
  final int setBreakThresholdMs;

  // ── State ──────────────────────────────────────────────
  StreamSubscription<AccelerometerEvent>? _sub;
  double _smoothed = 9.81;
  bool _inDown = false;
  DateTime? _downStarted;
  DateTime? _lastRepTime;
  bool _active = false;

  SquatDetectorService({
    required this.onRep,
    required this.onSetBreak,
    this.setBreakThresholdMs = 8000, // 8-second rest = new set
  });

  // ── Lifecycle ──────────────────────────────────────────
  void start() {
    if (_active) return;
    _active = true;
    _smoothed = 9.81;
    _inDown = false;
    _downStarted = null;
    _lastRepTime = null;

    _sub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval, // ~50 Hz
    ).listen(_onAccel, onError: (_) {});
  }

  void stop() {
    _active = false;
    _sub?.cancel();
    _sub = null;
  }

  // ── Core detection ─────────────────────────────────────
  void _onAccel(AccelerometerEvent e) {
    // Magnitude of total acceleration vector
    final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);

    // Exponential low-pass filter
    _smoothed = _alpha * mag + (1 - _alpha) * _smoothed;

    final now = DateTime.now();

    if (!_inDown && _smoothed < _descendThreshold) {
      // ── Entered down phase ─────────────────────────────
      _inDown = true;
      _downStarted = now;
    } else if (_inDown && _smoothed > _ascendThreshold) {
      // ── Returned to up phase ───────────────────────────
      final downDuration =
          now.difference(_downStarted!).inMilliseconds;
      _inDown = false;

      if (downDuration < _minDownMs) return; // too brief → noise

      // Debounce
      if (_lastRepTime != null &&
          now.difference(_lastRepTime!).inMilliseconds < _repDebounceMs) {
        return;
      }

      // Check for set break BEFORE updating _lastRepTime
      if (_lastRepTime != null &&
          now.difference(_lastRepTime!).inMilliseconds >
              setBreakThresholdMs) {
        onSetBreak();
      }

      _lastRepTime = now;
      onRep();
    }
  }

  /// Expose last rep time for external callers (e.g. live timer display).
  DateTime? get lastRepTime => _lastRepTime;
}