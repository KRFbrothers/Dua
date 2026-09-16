import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local Work-mode draft / task (on-device JSON only).
class WorkBoardItem {
  WorkBoardItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;

  WorkBoardItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
  }) {
    return WorkBoardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WorkBoardItem.fromJson(Map<String, dynamic> json) {
    return WorkBoardItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// CRUD store for Work board drafts — app documents JSON file (LOCAL only).
class WorkBoardStore {
  WorkBoardStore._();
  static final WorkBoardStore instance = WorkBoardStore._();

  static const _fileName = 'dua_work_board.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, _fileName));
  }

  Future<List<WorkBoardItem>> list() async {
    final f = await _file();
    if (!await f.exists()) return [];
    try {
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => WorkBoardItem.fromJson(Map<String, dynamic>.from(e)))
          .where((e) => e.id.isNotEmpty)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<WorkBoardItem> items) async {
    final f = await _file();
    await f.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        items.map((e) => e.toJson()).toList(),
      ),
    );
  }

  Future<WorkBoardItem> add({
    required String title,
    required String body,
  }) async {
    final items = await list();
    final item = WorkBoardItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    items.insert(0, item);
    await _write(items);
    return item;
  }

  Future<void> update(WorkBoardItem item) async {
    final items = await list();
    final i = items.indexWhere((e) => e.id == item.id);
    if (i < 0) return;
    items[i] = item;
    await _write(items);
  }

  Future<void> delete(String id) async {
    final items = await list();
    items.removeWhere((e) => e.id == id);
    await _write(items);
  }

  /// Title = first line truncated; body = full reply.
  static String titleFromReply(String reply, {int maxLen = 48}) {
    final first = reply
        .trim()
        .split(RegExp(r'[\r\n]+'))
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => 'Work draft');
    final t = first.trim();
    if (t.length <= maxLen) return t;
    return '${t.substring(0, maxLen - 1)}…';
  }
}
