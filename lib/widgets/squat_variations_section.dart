// ── squat_variations_section.dart ─────────────────────────────────────────
// Drop this file into lib/widgets/ and add _SquatVariationsSection() at the
// bottom of SquatTrackingScreen's Column (after the Live sensor status block).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  DATA
// ══════════════════════════════════════════════════════════════════════════════

class _SquatVariant {
  final String name;
  final String tag;      // e.g. "Glutes · Balance"
  final String emoji;
  final String difficulty; // 'Beginner' | 'Intermediate' | 'Advanced'
  final Color accentColor;
  final List<_Step> steps;
  final String tip;

  const _SquatVariant({
    required this.name,
    required this.tag,
    required this.emoji,
    required this.difficulty,
    required this.accentColor,
    required this.steps,
    required this.tip,
  });
}

class _Step {
  final String phase;   // e.g. "Setup", "Descent", "Ascent"
  final String cue;     // Short coaching cue
  final String detail;  // Longer description
  const _Step(this.phase, this.cue, this.detail);
}

const _variants = <_SquatVariant>[
  _SquatVariant(
    name: 'Bulgarian Split',
    tag: 'Glutes · Balance',
    emoji: '🦵',
    difficulty: 'Intermediate',
    accentColor: Color(0xFF7FFFD4),   // aquamarine
    tip: 'Keep 70% of your weight on the front foot. The rear leg is just a kickstand.',
    steps: [
      _Step('Setup',   'Rear foot elevated',
          'Stand 2 ft in front of a bench. Place top of rear foot on the bench. Hands on hips or holding dumbbells.'),
      _Step('Descent', 'Vertical shin, tall chest',
          'Bend front knee and lower your hips straight down. Front shin stays vertical. Rear knee tracks toward the floor.'),
      _Step('Bottom',  'Thigh parallel or below',
          'Pause briefly. Front thigh should be at or below parallel. Avoid letting front knee cave inward.'),
      _Step('Ascent',  'Drive through front heel',
          'Push through the heel of the front foot to return to start. Squeeze the glute at the top.'),
    ],
  ),
  _SquatVariant(
    name: 'Sumo Squat',
    tag: 'Inner Thighs · Glutes',
    emoji: '🏋️',
    difficulty: 'Beginner',
    accentColor: Color(0xFFFFD700),   // gold
    tip: 'Point toes out at 45°. Think "spread the floor" with your feet — this activates the adductors.',
    steps: [
      _Step('Setup',   'Wide stance, toes out',
          'Stand with feet 1.5–2× shoulder-width. Turn toes out ~45°. Hands clasped at chest or holding one dumbbell.'),
      _Step('Descent', 'Knees track over toes',
          'Push knees outward (in the direction of your toes) as you lower. Keep your torso upright.'),
      _Step('Bottom',  'Hips below knees',
          'Lower until thighs are at or below parallel. Keep chest up and spine neutral.'),
      _Step('Ascent',  'Squeeze glutes at top',
          'Drive through the whole foot. Actively squeeze glutes and push knees out as you rise.'),
    ],
  ),
  _SquatVariant(
    name: 'Goblet Squat',
    tag: 'Full Lower Body · Core',
    emoji: '🏆',
    difficulty: 'Beginner',
    accentColor: Color(0xFFFF6B6B),   // coral
    tip: 'Use the weight as a counterbalance — it lets you sit deeper and keep a more upright torso.',
    steps: [
      _Step('Setup',   'Hold weight at chest',
          'Hold a dumbbell or kettlebell vertically at chest height, elbows tucked. Feet shoulder-width, toes out slightly.'),
      _Step('Descent', 'Elbows inside knees',
          'As you descend, drive elbows between your knees to keep them tracking wide. Sit deep.'),
      _Step('Bottom',  'Pause and "open the hips"',
          'At the bottom, use your elbows to gently push your knees outward, deepening the hip stretch.'),
      _Step('Ascent',  'Chest leads the way up',
          'Lead with your chest, not your hips. Keep the weight close to your body as you stand.'),
    ],
  ),
  _SquatVariant(
    name: 'Pause Squat',
    tag: 'Strength · Control',
    emoji: '⏸️',
    difficulty: 'Intermediate',
    accentColor: Color(0xFFB39DDB),   // lavender
    tip: 'The pause eliminates the "stretch reflex" bounce, forcing your muscles to work harder from a dead stop.',
    steps: [
      _Step('Setup',   'Standard squat stance',
          'Feet shoulder-width, toes slightly out. Can be done with bodyweight, barbell, or dumbbells.'),
      _Step('Descent', 'Controlled and slow',
          'Lower over 2–3 seconds. Focus on maintaining tension throughout the entire descent.'),
      _Step('Hold',    '2–3 second pause',
          'At parallel or below, hold completely still. Maintain full tension — do not relax into the bottom.'),
      _Step('Ascent',  'Explode from the pause',
          'Drive up as fast as possible. The contrast between the slow pause and explosive drive builds power.'),
    ],
  ),
  _SquatVariant(
    name: 'Pistol Squat',
    tag: 'Unilateral · Mobility',
    emoji: '🎯',
    difficulty: 'Advanced',
    accentColor: Color(0xFFFF8C42),   // orange
    tip: 'Build toward this with assisted versions: hold a TRX, squat to a box, or counterbalance with a light weight.',
    steps: [
      _Step('Setup',   'One foot, arms forward',
          'Stand on one foot. Extend the other leg and both arms straight in front for balance.'),
      _Step('Descent', 'Heel stays on floor',
          'Slowly lower on the standing leg. Keep the elevated leg parallel to the floor. Heel must stay planted.'),
      _Step('Bottom',  'Hamstring touches calf',
          'Aim for full depth — hamstring touching calf. Most people need ankle/hip mobility work to reach this.'),
      _Step('Ascent',  'Press the floor away',
          'Imagine pressing the floor away from you. Use core and glute to drive back up without losing balance.'),
    ],
  ),
  _SquatVariant(
    name: 'Box Squat',
    tag: 'Posterior Chain · Power',
    emoji: '📦',
    difficulty: 'Beginner',
    accentColor: Color(0xFF4FC3F7),   // light blue
    tip: 'Sit back to the box — do not sit down. The difference in hip hinge teaches proper posterior loading.',
    steps: [
      _Step('Setup',   'Box at parallel height',
          'Position a box or bench so your hips are at parallel when seated. Stand in front with feet shoulder-width.'),
      _Step('Descent', 'Sit back, not down',
          'Push hips back and down as if reaching for the box behind you. Weight shifts toward heels.'),
      _Step('Touch',   'Light touch, stay tight',
          'Lightly touch the box — do not fully relax or "plop." Maintain tension in legs and core.'),
      _Step('Ascent',  'Drive hips forward',
          'Push floor away and drive hips forward. Stand tall with glutes squeezed at the top.'),
    ],
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  SECTION WIDGET  (add this inside SquatTrackingScreen's Column)
// ══════════════════════════════════════════════════════════════════════════════

class SquatVariationsSection extends StatelessWidget {
  const SquatVariationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Section header
        Row(
          children: const [
            Text(
              'Variations',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '— tap to learn',
              style: TextStyle(color: Colors.white30, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 3×2 grid of variant chips
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 110 / 96,
          children: _variants
              .map((v) => _VariantChip(variant: v))
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Single chip ────────────────────────────────────────────────────────────
class _VariantChip extends StatelessWidget {
  final _SquatVariant variant;
  const _VariantChip({required this.variant});

  Color get _diffColor {
    switch (variant.difficulty) {
      case 'Beginner':     return Colors.greenAccent;
      case 'Intermediate': return Colors.yellowAccent;
      case 'Advanced':     return Colors.redAccent;
      default:             return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPreview(context, variant),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: variant.accentColor.withOpacity(0.35)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // emoji + difficulty dot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(variant.emoji, style: const TextStyle(fontSize: 18)),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _diffColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              variant.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              variant.tag,
              style: const TextStyle(color: Colors.white38, fontSize: 9),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  BOTTOM SHEET PREVIEW
// ══════════════════════════════════════════════════════════════════════════════

void _openPreview(BuildContext context, _SquatVariant variant) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _VariantPreviewSheet(variant: variant),
  );
}

class _VariantPreviewSheet extends StatefulWidget {
  final _SquatVariant variant;
  const _VariantPreviewSheet({required this.variant});

  @override
  State<_VariantPreviewSheet> createState() => _VariantPreviewSheetState();
}

class _VariantPreviewSheetState extends State<_VariantPreviewSheet>
    with TickerProviderStateMixin {
  int _activeStep = 0;
  late final AnimationController _stepAnim;
  late final AnimationController _phaseAnim;
  late Timer _autoTimer;
  bool _paused = false;

  static const _phaseDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _stepAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _phaseAnim = AnimationController(
      vsync: this,
      duration: _phaseDuration,
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed && !_paused) _nextStep();
    });
    _phaseAnim.forward();
  }

  void _nextStep() {
    setState(() {
      _activeStep = (_activeStep + 1) % widget.variant.steps.length;
    });
    _stepAnim.forward(from: 0);
    _phaseAnim.forward(from: 0);
  }

  void _goTo(int i) {
    setState(() {
      _activeStep = i;
      _paused = true;
    });
    _stepAnim.forward(from: 0);
    _phaseAnim.stop();
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _phaseAnim.stop();
    } else {
      _phaseAnim.forward(from: _phaseAnim.value);
    }
  }

  @override
  void dispose() {
    _stepAnim.dispose();
    _phaseAnim.dispose();
    super.dispose();
  }

  Color get _diffColor {
    switch (widget.variant.difficulty) {
      case 'Beginner':     return Colors.greenAccent;
      case 'Intermediate': return Colors.yellowAccent;
      case 'Advanced':     return Colors.redAccent;
      default:             return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.variant;
    final step = v.steps[_activeStep];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Text(v.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(v.tag,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border:
                            Border.all(color: _diffColor.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(4),
                            color: _diffColor.withOpacity(0.07),
                          ),
                          child: Text(
                            v.difficulty,
                            style: TextStyle(
                                color: _diffColor, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Step visualizer ───────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(
                  color: v.accentColor.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phase label + progress bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: v.accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        step.phase.toUpperCase(),
                        style: TextStyle(
                          color: v.accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_activeStep + 1} / ${v.steps.length}',
                      style: const TextStyle(
                          color: Colors.white24, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Auto-progress bar
                AnimatedBuilder(
                  animation: _phaseAnim,
                  builder: (_, __) => LinearProgressIndicator(
                    value: _paused ? null : _phaseAnim.value,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(
                        v.accentColor.withOpacity(0.6)),
                    minHeight: 2,
                  ),
                ),
                const SizedBox(height: 14),

                // Step body — fade transition
                FadeTransition(
                  opacity: _stepAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Big coaching cue
                      Text(
                        '"${step.cue}"',
                        style: TextStyle(
                          color: v.accentColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Detail
                      Text(
                        step.detail,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Step dot nav + pause/play
                Row(
                  children: [
                    // Dots
                    ...List.generate(v.steps.length, (i) {
                      final active = i == _activeStep;
                      return GestureDetector(
                        onTap: () => _goTo(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 18 : 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: active
                                ? v.accentColor
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                    // Pause / play
                    GestureDetector(
                      onTap: _togglePause,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _paused ? Icons.play_arrow : Icons.pause,
                          color: Colors.white54,
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Next
                    GestureDetector(
                      onTap: _nextStep,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: v.accentColor.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(6),
                          color: v.accentColor.withOpacity(0.08),
                        ),
                        child: Text(
                          'Next →',
                          style: TextStyle(
                              color: v.accentColor, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Pro tip ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white.withOpacity(0.03),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    v.tip,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      height: 1.45,
                    ),
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