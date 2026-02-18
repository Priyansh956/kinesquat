import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/dark_card.dart';

class SquatTrackingScreen extends StatelessWidget {
  const SquatTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pct = (state.progress * 100).toInt();
    final filters = ['All', 'Today', 'Weekly', 'Monthly', 'Yearly'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isTracking ? 'Tracking\nyour squats\nnow' : 'Kinesquat',
                  style: const TextStyle(
                    fontSize: 24, color: Colors.white, height: 1.35,
                  ),
                ),
                GestureDetector(
                  onTap: () => state.isTracking
                      ? state.stopTracking()
                      : state.startTracking(),
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      color: state.isTracking ? Colors.white24 : Colors.transparent,
                    ),
                    child: Icon(
                      state.isTracking ? Icons.stop : Icons.play_arrow,
                      color: Colors.white, size: 26,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Progress card ─────────────────────────────────────
            DarkCard(
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64, height: 64,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: state.progress),
                          duration: const Duration(milliseconds: 400),
                          builder: (_, v, __) => CircularProgressIndicator(
                            value: v, strokeWidth: 3,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ),
                      Text('$pct%',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Squatting',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('Legs',
                          style: TextStyle(
                              color: Colors.white, fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Filter tabs ───────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = filters[i];
                  final sel = f == state.filter;
                  return GestureDetector(
                    onTap: () => state.setFilter(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: sel ? Colors.white : Colors.white38),
                        color: sel ? Colors.white12 : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              color: sel ? Colors.white : Colors.white60,
                              fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Sets card ─────────────────────────────────────────
            DarkCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sets',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      _AnimatedCount(
                          value: state.isTracking ? state.liveSets : state.totalSets),
                    ],
                  ),
                  if (state.isTracking)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _OutlineButton(
                            label: '+ Set', onTap: state.manualIncrementSet),
                        const SizedBox(height: 4),
                        // current set reps label
                        Text(
                          'Set ${state.liveSets + 1}: ${state.currentSetReps} reps',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    )
                  else
                    const Icon(Icons.fitness_center,
                        color: Colors.white24, size: 44),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Reps card ─────────────────────────────────────────
            DarkCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reps',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 8),
                      _AnimatedCount(
                          value: state.isTracking ? state.liveReps : state.totalReps),
                    ],
                  ),
                  if (state.isTracking)
                    Column(
                      children: [
                        _OutlineButton(
                            label: '+ Rep', onTap: state.manualIncrementRep),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: state.stopTracking,
                          child: const Text('Done ✓',
                              style: TextStyle(
                                  color: Colors.greenAccent, fontSize: 13)),
                        ),
                      ],
                    )
                  else
                    const Icon(Icons.accessibility_new,
                        color: Colors.white24, size: 44),
                ],
              ),
            ),

            // ── Sensor status + break timer ───────────────────────
            if (state.isTracking) ...[
              const SizedBox(height: 12),
              _LiveStatus(state: state),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Smooth number animation ────────────────────────────────
class _AnimatedCount extends StatelessWidget {
  final int value;
  const _AnimatedCount({required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 300),
      builder: (_, v, __) => Text('$v',
          style: const TextStyle(
              color: Colors.white, fontSize: 36,
              fontWeight: FontWeight.bold)),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white38),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white10,
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }
}

// ── Live sensor status + break timer ──────────────────────
class _LiveStatus extends StatelessWidget {
  final AppState state;
  const _LiveStatus({required this.state});

  String _formatBreak(int ms) {
    final s = ms ~/ 1000;
    if (s < 60) return '${s}s';
    return '${s ~/ 60}m ${s % 60}s';
  }

  @override
  Widget build(BuildContext context) {
    final hasRep = state.lastRepTime != null;
    final breakSec = state.msSinceLastRep ~/ 1000;
    // 8-second threshold for set break
    final inBreak = breakSec >= 8;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: inBreak
              ? Colors.orangeAccent.withOpacity(0.6)
              : Colors.greenAccent.withOpacity(0.4),
        ),
        borderRadius: BorderRadius.circular(6),
        color: inBreak
            ? Colors.orangeAccent.withOpacity(0.05)
            : Colors.greenAccent.withOpacity(0.05),
      ),
      child: Row(
        children: [
          // Pulsing dot
          _PulsingDot(color: inBreak ? Colors.orangeAccent : Colors.greenAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasRep
                      ? (inBreak
                      ? '⏸ Rest: ${_formatBreak(state.msSinceLastRep)} — next rep starts new set'
                      : '● Sensor active · last rep ${_formatBreak(state.msSinceLastRep)} ago')
                      : '● Sensor active — squat to auto-count reps',
                  style: TextStyle(
                    color: inBreak ? Colors.orangeAccent : Colors.greenAccent,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}