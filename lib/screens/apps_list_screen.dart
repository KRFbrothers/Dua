import 'package:flutter/material.dart';

import '../offline/apps_service.dart';
import '../theme/dua_colors.dart';

class AppsListScreen extends StatefulWidget {
  const AppsListScreen({super.key});

  @override
  State<AppsListScreen> createState() => _AppsListScreenState();
}

class _AppsListScreenState extends State<AppsListScreen> {
  List<LaunchableApp> _apps = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apps = await AppsService.listLaunchable(withIcon: true);
      if (!mounted) return;
      setState(() {
        _apps = apps;
        _loading = false;
        if (apps.isEmpty) {
          _error = 'No launchable apps found (Android only).';
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not list installed apps.';
        });
      }
    }
  }

  List<LaunchableApp> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _apps;
    return _apps
        .where(
          (a) =>
              a.name.toLowerCase().contains(q) ||
              a.packageName.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _launch(LaunchableApp app) async {
    final ok = await AppsService.launch(app.packageName);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: DuaColors.surfaceElevated,
          content: Text(
            'Could not open ${app.name}',
            style: const TextStyle(color: DuaColors.textPrimary),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Apps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: DuaColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search apps…',
                prefixIcon: Icon(Icons.search, color: DuaColors.textMuted),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: DuaColors.cyan),
                  )
                : items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _error ?? 'No apps match.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: DuaColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final app = items[index];
                          return Material(
                            color: DuaColors.card,
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(
                                  color: DuaColors.borderNeon,
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor:
                                    DuaColors.purple.withValues(alpha: 0.15),
                                backgroundImage: app.icon != null
                                    ? MemoryImage(app.icon!)
                                    : null,
                                child: app.icon == null
                                    ? const Icon(
                                        Icons.apps,
                                        color: DuaColors.purple,
                                        size: 20,
                                      )
                                    : null,
                              ),
                              title: Text(
                                app.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: DuaColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                app.packageName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: DuaColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.launch,
                                color: DuaColors.cyanSoft,
                                size: 18,
                              ),
                              onTap: () => _launch(app),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
