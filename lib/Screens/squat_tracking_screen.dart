import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/dark_card.dart';

class SquatTrackingScreen extends StatefulWidget {
  const SquatTrackingScreen({super.key});

  @override
  State<SquatTrackingScreen> createState() => _SquatTrackingScreenState();
}

class _SquatTrackingScreenState extends State<SquatTrackingScreen> {
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  void _startWithWeight(AppState state) {
    final kg = double.tryParse(_weightCtrl.text) ?? 0;
    state.setAddedWeight(kg);
    state.startTracking();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pct = (state.progress * 100).toInt();
    final filters = ['All', 'Today', 'Weekly', 'Monthly', 'Yearly'];
    final restSec = state.restThresholdMs ~/ 1000;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isTracking
                      ? 'Tracking\nyour squats\nnow'
                      : 'Kinesquat',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
                if (!state.isTracking)
                  GestureDetector(
                    onTap: () => _startWithWeight(state),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 26),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: state.stopTracking,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        color: Colors.white24,
                      ),
                      child: const Icon(Icons.stop,
                          color: Colors.white, size: 26),
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
                        width: 64,
                        height: 64,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: state.progress),
                          duration: const Duration(milliseconds: 400),
                          builder: (_, v, __) => CircularProgressIndicator(
                            value: v,
                            strokeWidth: 3,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ),
                      Text('$pct%',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Squatting',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text('Legs',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      if (state.isTracking) ...[
                        const SizedBox(height: 4),
                        Text(
                          state.addedWeightKg > 0
                              ? '${state.totalSessionWeightKg.toStringAsFixed(1)} kg total'
                              : 'Bodyweight',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Weight input (shown only before session starts) ────
            if (!state.isTracking) ...[
              _WeightPanel(
                ctrl: _weightCtrl,
                bodyWeight: state.bodyWeightKg,
                onStart: () => _startWithWeight(state),
              ),
              const SizedBox(height: 12),
            ],

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: sel ? Colors.white : Colors.white38),
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
                          style: TextStyle(
                              color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 6),
                      _AnimatedCount(
                          value: state.isTracking
                              ? state.liveSets
                              : state.totalSets),
                    ],
                  ),
                  if (state.isTracking)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _OutlineButton(
                            label: '+ Set',
                            onTap: state.manualIncrementSet),
                        const SizedBox(height: 4),
                        Text(
                          'Set ${state.liveSets + 1}  ·  ${state.currentSetReps} reps',
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
                          style: TextStyle(
                              color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 6),
                      _AnimatedCount(
                          value: state.isTracking
                              ? state.liveReps
                              : state.totalReps),
                      if (state.isTracking && state.liveReps > 0)
                        Text(
                          '~${state.liveSessionKcal.toStringAsFixed(1)} kcal',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                    ],
                  ),
                  if (state.isTracking)
                    Column(
                      children: [
                        _OutlineButton(
                            label: '+ Rep',
                            onTap: state.manualIncrementRep),
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

            // ── Live sensor status ─────────────────────────────────
            if (state.isTracking) ...[
              const SizedBox(height: 12),
              _LiveStatus(state: state, restThresholdSec: restSec),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Weight input panel ─────────────────────────────────────
class _WeightPanel extends StatefulWidget {
  final TextEditingController ctrl;
  final double bodyWeight;
  final VoidCallback onStart;
  const _WeightPanel(
      {required this.ctrl,
        required this.bodyWeight,
        required this.onStart});

  @override
  State<_WeightPanel> createState() => _WeightPanelState();
}

class _WeightPanelState extends State<_WeightPanel> {
  bool _addingWeight = false;

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_weight_outlined,
                  color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              const Text('Session weight',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              const Spacer(),
              // Toggle between bodyweight and weighted
              GestureDetector(
                onTap: () => setState(() {
                  _addingWeight = !_addingWeight;
                  if (!_addingWeight) widget.ctrl.clear();
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: _addingWeight
                            ? Colors.white
                            : Colors.white38),
                    borderRadius: BorderRadius.circular(20),
                    color: _addingWeight
                        ? Colors.white12
                        : Colors.transparent,
                  ),
                  child: Text(
                    _addingWeight ? 'Weighted ✓' : '+ Add weight',
                    style: TextStyle(
                      color: _addingWeight ? Colors.white : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_addingWeight) ...[
            // Bodyweight mode
            Row(
              children: [
                const Icon(Icons.person_outline,
                    color: Colors.white38, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Bodyweight only  ·  ${widget.bodyWeight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Rest threshold auto-applied from your settings.',
              style:
              TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ] else ...[
            // Weighted mode
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.ctrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '0',
                      hintStyle:
                      TextStyle(color: Colors.white24, fontSize: 28),
                      suffixText: 'kg',
                      suffixStyle:
                      TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Body ${widget.bodyWeight.toStringAsFixed(1)} kg + extra weight = total load',
              style: const TextStyle(
                  color: Colors.white24, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Animated number ────────────────────────────────────────
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
              color: Colors.white,
              fontSize: 36,
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
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

// ── Live sensor status bar ─────────────────────────────────
class _LiveStatus extends StatelessWidget {
  final AppState state;
  final int restThresholdSec;
  const _LiveStatus(
      {required this.state, required this.restThresholdSec});

  String _fmt(int ms) {
    final s = ms ~/ 1000;
    return s < 60 ? '${s}s' : '${s ~/ 60}m ${s % 60}s';
  }

  @override
  Widget build(BuildContext context) {
    final hasRep = state.lastRepTime != null;
    final breakSec = state.msSinceLastRep ~/ 1000;
    final inBreak = breakSec >= restThresholdSec;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          _PulsingDot(
              color: inBreak ? Colors.orangeAccent : Colors.greenAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasRep
                  ? (inBreak
                  ? '⏸  Rest ${_fmt(state.msSinceLastRep)} — next rep opens new set'
                  : '●  ${_fmt(state.msSinceLastRep)} since last rep  ·  set break in ${restThresholdSec - breakSec}s')
                  : '●  Sensor active — squat to auto-count',
              style: TextStyle(
                color: inBreak ? Colors.orangeAccent : Colors.greenAccent,
                fontSize: 11,
              ),
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
        width: 8,
        height: 8,
        decoration: BoxDecoration(
            color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}