import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/dark_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _repCtrl;
  late TextEditingController _setCtrl;
  late TextEditingController _bodyWeightCtrl;
  final _importCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final state = context.read<AppState>();
      _repCtrl = TextEditingController(text: '${state.repGoal}');
      _setCtrl = TextEditingController(text: '${state.setGoal}');
      _bodyWeightCtrl = TextEditingController(
          text: state.bodyWeightKg.toStringAsFixed(1));
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _repCtrl.dispose();
    _setCtrl.dispose();
    _bodyWeightCtrl.dispose();
    _importCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAll() async {
    final state = context.read<AppState>();
    final reps = int.tryParse(_repCtrl.text);
    final sets = int.tryParse(_setCtrl.text);
    final bw = double.tryParse(_bodyWeightCtrl.text);
    if (reps != null) await state.updateRepGoal(reps);
    if (sets != null) await state.updateSetGoal(sets);
    if (bw != null && bw > 0) await state.updateBodyWeight(bw);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Settings saved!')));
    }
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Import Data',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _importCtrl,
          style: const TextStyle(color: Colors.white),
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Paste JSON here',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white),
            onPressed: () async {
              final ok = await context
                  .read<AppState>()
                  .storage
                  .importData(_importCtrl.text);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        ok ? 'Imported!' : 'Invalid JSON')));
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final data = context.read<AppState>().storage.exportData();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Export Data',
            style: TextStyle(color: Colors.white)),
        content: SelectableText(data,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close',
                  style: TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }

  String _restLabel(int ms) {
    final s = ms ~/ 1000;
    if (s <= 3) return 'Bodyweight · $s s';
    if (s <= 6) return 'Light weight · $s s';
    if (s <= 9) return 'Moderate weight · $s s';
    return 'Heavy weight · $s s';
  }

  Color _restColor(int ms) {
    final s = ms ~/ 1000;
    if (s <= 3) return Colors.greenAccent;
    if (s <= 6) return Colors.yellowAccent;
    if (s <= 9) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final restMs = state.restThresholdMs;
    final restSec = restMs ~/ 1000;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back',
                style: TextStyle(fontSize: 26, color: Colors.white)),
            const SizedBox(height: 20),

            // ── Goals row ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: DarkCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rep Goal',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _repCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Text('current: ${state.repGoal}',
                            style: const TextStyle(
                                color: Colors.white24, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DarkCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Set Goal',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _setCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Text('current: ${state.setGoal}',
                            style: const TextStyle(
                                color: Colors.white24, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Body weight ───────────────────────────────────────
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          color: Colors.white54, size: 16),
                      const SizedBox(width: 6),
                      const Text('Body Weight',
                          style: TextStyle(
                              color: Colors.white, fontSize: 14)),
                      const Spacer(),
                      const Text('used for calorie estimates',
                          style: TextStyle(
                              color: Colors.white24, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _bodyWeightCtrl,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(' kg',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Rest threshold slider ─────────────────────────────
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: Colors.white54, size: 16),
                          const SizedBox(width: 6),
                          const Text('Set break threshold',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14)),
                        ],
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: _restColor(restMs).withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(20),
                          color: _restColor(restMs).withOpacity(0.08),
                        ),
                        child: Text(
                          _restLabel(restMs),
                          style: TextStyle(
                              color: _restColor(restMs), fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'No movement for this long = rest detected → next rep starts a new set.',
                    style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.4),
                  ),
                  const SizedBox(height: 12),

                  // Slider: 2s – 15s
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: _restColor(restMs),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white12,
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: restSec.toDouble(),
                      min: 2,
                      max: 15,
                      divisions: 13,
                      onChanged: (v) =>
                          state.updateRestThreshold(v.toInt() * 1000),
                    ),
                  ),

                  // Tick labels
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _tickLabel('2s', restSec == 2),
                        _tickLabel('5s', restSec == 5),
                        _tickLabel('8s', restSec == 8),
                        _tickLabel('12s', restSec == 12),
                        _tickLabel('15s', restSec == 15),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Quick preset chips
                  Wrap(
                    spacing: 8,
                    children: [
                      _PresetChip(
                        label: 'Bodyweight',
                        sub: '3s',
                        active: restSec == 3,
                        onTap: () => state.updateRestThreshold(3000),
                      ),
                      _PresetChip(
                        label: 'Light weight',
                        sub: '5s',
                        active: restSec == 5,
                        onTap: () => state.updateRestThreshold(5000),
                      ),
                      _PresetChip(
                        label: 'Moderate',
                        sub: '8s',
                        active: restSec == 8,
                        onTap: () => state.updateRestThreshold(8000),
                      ),
                      _PresetChip(
                        label: 'Heavy',
                        sub: '12s',
                        active: restSec == 12,
                        onTap: () => state.updateRestThreshold(12000),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Save ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Save Settings',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),

            // ── Import / Export ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showImportDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Import data'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _showExportDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Export data'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Clear data ────────────────────────────────────────
            Center(
              child: TextButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text('Clear all sessions?',
                          style: TextStyle(color: Colors.white)),
                      content: const Text(
                          'This permanently deletes all workout history.',
                          style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: Colors.white54))),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete',
                                style: TextStyle(
                                    color: Colors.redAccent))),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await context.read<AppState>().clearAllData();
                  }
                },
                child: const Text('Clear all data',
                    style: TextStyle(
                        color: Colors.redAccent, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tickLabel(String t, bool active) => Text(
    t,
    style: TextStyle(
        color: active ? Colors.white : Colors.white24,
        fontSize: 9),
  );
}

// ── Preset chip ────────────────────────────────────────────
class _PresetChip extends StatelessWidget {
  final String label;
  final String sub;
  final bool active;
  final VoidCallback onTap;
  const _PresetChip(
      {required this.label,
        required this.sub,
        required this.active,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white12 : Colors.transparent,
          border: Border.all(
              color: active ? Colors.white : Colors.white24),
          borderRadius: BorderRadius.circular(20),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: label,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.white54,
                      fontSize: 11)),
              TextSpan(
                  text: '  $sub',
                  style: TextStyle(
                      color: active ? Colors.white54 : Colors.white24,
                      fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}