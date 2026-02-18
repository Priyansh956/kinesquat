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
  late final TextEditingController _repCtrl;
  late final TextEditingController _setCtrl;
  final TextEditingController _importCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    _repCtrl = TextEditingController(text: '${state.repGoal}');
    _setCtrl = TextEditingController(text: '${state.setGoal}');
  }

  @override
  void dispose() {
    _repCtrl.dispose();
    _setCtrl.dispose();
    _importCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    final state = context.read<AppState>();
    final reps = int.tryParse(_repCtrl.text);
    final sets = int.tryParse(_setCtrl.text);
    if (reps != null) await state.updateRepGoal(reps);
    if (sets != null) await state.updateSetGoal(sets);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Goals saved!')));
    }
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title:
        const Text('Import Data', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _importCtrl,
          style: const TextStyle(color: Colors.white),
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Paste JSON data here',
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
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              final ok = await context
                  .read<AppState>()
                  .storage
                  .importData(_importCtrl.text);
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        ok ? 'Data imported!' : 'Invalid JSON format')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
            ),
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
                style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch so progress ring updates when goals change
    final state = context.watch<AppState>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back',
                style: TextStyle(fontSize: 26, color: Colors.white)),
            const SizedBox(height: 20),

            // ── Rep Goal ───────────────────────────────────────────
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rep Goal',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      Text('current: ${state.repGoal}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _repCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Set Goal ───────────────────────────────────────────
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Set Goal',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      Text('current: ${state.setGoal}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _setCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Save button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Save Goals', style: TextStyle(fontSize: 16)),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Export data'),
                  ),
                ),
              ],
            ),

            // ── Detector sensitivity info ──────────────────────────
            const SizedBox(height: 16),
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Auto-detection',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  SizedBox(height: 8),
                  Text(
                    '• Phone in pocket or held upright\n'
                        '• Rep detected on stand-up phase\n'
                        '• 8 sec rest between reps = new set\n'
                        '• Tap + Rep / + Set to override',
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.6),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Clear data ─────────────────────────────────────────
            Center(
              child: TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text('Clear all data?',
                          style: TextStyle(color: Colors.white)),
                      content: const Text(
                          'This permanently deletes all sessions.',
                          style: TextStyle(color: Colors.white70)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.white54)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await context.read<AppState>().clearAllData();
                  }
                },
                child: const Text('Clear all data',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}