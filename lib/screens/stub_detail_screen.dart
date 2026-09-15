import 'package:flutter/material.dart';

import '../theme/dua_colors.dart';
import '../widgets/storage_pie.dart';

class StubDetailScreen extends StatelessWidget {
  const StubDetailScreen({
    super.key,
    required this.title,
    this.showStoragePie = false,
    this.subtitle = 'Stub — real device APIs come in a later phase.',
  });

  final String title;
  final bool showStoragePie;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showStoragePie) ...[
                const StoragePieChart(),
                const SizedBox(height: 28),
              ] else ...[
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: DuaColors.cyan.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: DuaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: DuaColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const Text(
                'ALWAYS WITH YOU',
                style: TextStyle(
                  color: DuaColors.cyanSoft,
                  fontSize: 10,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
