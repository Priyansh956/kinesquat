import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:sensors_plus/sensors_plus.dart';

/// Fires [onRep] whenever a squat rep is confidently detected.
/// Fires [onSetBreak] whenever inter-rep gap exceeds [setBreakThresholdMs].
class SquatDetectorService {
  final VoidCallback onRep;
  final VoidCallback onSetBreak;

  // Low-pass smoothing factor
  static const double _alpha = 0.15;
  // Magnitude drops below this → descending
  static const double _descendThreshold = 8.8;
  // Magnitude rises above this → ascending (rep complete)
  static const double _ascendThreshold = 9.6;
  // Minimum down-phase duration to count (ms)
  static const int _minDownMs = 200;
  // Minimum ms between two rep detections
  static const int _repDebounceMs = 800;

  /// Mutable — updated live from AppState when user changes the slider.
  int setBreakThresholdMs;

  StreamSubscription<AccelerometerEvent>? _sub;
  double _smoothed = 9.81;
  bool _inDown = false;
  DateTime? _downStarted;
  DateTime? _lastRepTime;
  bool _active = false;

  SquatDetectorService({
    required this.onRep,
    required this.onSetBreak,
    this.setBreakThresholdMs = 5000,
  });

  void start() {
    if (_active) return;
    _active = true;
    _smoothed = 9.81;
    _inDown = false;
    _downStarted = null;
    _lastRepTime = null;

    _sub = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_onAccel, onError: (_) {});
  }

  void stop() {
    _active = false;
    _sub?.cancel();
    _sub = null;
  }

  void _onAccel(AccelerometerEvent e) {
    final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    _smoothed = _alpha * mag + (1 - _alpha) * _smoothed;

    final now = DateTime.now();

    if (!_inDown && _smoothed < _descendThreshold) {
      _inDown = true;
      _downStarted = now;
    } else if (_inDown && _smoothed > _ascendThreshold) {
      final downMs = now.difference(_downStarted!).inMilliseconds;
      _inDown = false;
      if (downMs < _minDownMs) return;

      if (_lastRepTime != null &&
          now.difference(_lastRepTime!).inMilliseconds < _repDebounceMs) {
        return;
      }

      // Set break check before updating last rep time
      if (_lastRepTime != null &&
          now.difference(_lastRepTime!).inMilliseconds > setBreakThresholdMs) {
        onSetBreak();
      }

      _lastRepTime = now;
      onRep();
    }
  }

  DateTime? get lastRepTime => _lastRepTime;
}