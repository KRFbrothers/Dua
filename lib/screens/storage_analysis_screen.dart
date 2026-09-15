import 'package:flutter/material.dart';

import '../offline/storage_stats_service.dart';
import '../theme/dua_colors.dart';
import '../widgets/storage_pie.dart';

class StorageAnalysisScreen extends StatefulWidget {
  const StorageAnalysisScreen({super.key});

  @override
  State<StorageAnalysisScreen> createState() => _StorageAnalysisScreenState();
}

class _StorageAnalysisScreenState extends State<StorageAnalysisScreen> {
  StorageStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final stats = await StorageStatsService.load();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Storage Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: _loading || stats == null
          ? const Center(
              child: CircularProgressIndicator(color: DuaColors.cyan),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                children: [
                  StoragePieChart(
                    usedFraction: stats.usedFraction,
                    centerPercentLabel:
                        '${(stats.usedFraction * 100).round()}%',
                    centerCaption: 'used · ${stats.sourceLabel}',
                  ),
                  const SizedBox(height: 28),
                  _StatCard(
                    label: 'Used',
                    value: stats.usedLabel,
                    accent: DuaColors.purple,
                  ),
                  const SizedBox(height: 10),
                  _StatCard(
                    label: 'Free',
                    value: stats.freeLabel,
                    accent: DuaColors.cyan,
                  ),
                  const SizedBox(height: 10),
                  _StatCard(
                    label: 'Total',
                    value: stats.totalLabel,
                    accent: DuaColors.blue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    stats.sourceLabel == 'Demo estimate'
                        ? 'Live disk stats unavailable — showing improved demo.'
                        : 'Totals from ${stats.sourceLabel}. Category split is illustrative.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: DuaColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DuaColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: DuaColors.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: DuaColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
