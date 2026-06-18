import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local/database.dart';
import '../../core/env.dart';

const _lastPullKey = 'last_pull_time';

class SupabaseSync {
  final AppDatabase db;

  SupabaseSync({required this.db});

  SupabaseClient get _client => Supabase.instance.client;

  bool get _isAuthenticated => _client.auth.currentUser != null;

  Future<void> sync() async {
    if (!Env.hasSupabase || !_isAuthenticated) return;
    try {
      await _push();
      await _pull();
    } catch (_) {
      // silent retry next foreground
    }
  }

  Future<void> _push() async {
    final userId = _client.auth.currentUser!.id;

    final unsyncedTodos = await db.getUnsyncedTodos();
    for (final todo in unsyncedTodos) {
      await _client.from('todos').upsert({
        'id': todo.id,
        'user_id': userId,
        'date': _formatDate(todo.date),
        'title': todo.title,
        'is_done': todo.isDone,
        'sort_order': todo.sortOrder,
        'created_at': todo.createdAt.toUtc().toIso8601String(),
        'updated_at': todo.updatedAt.toUtc().toIso8601String(),
      });
      await db.markTodoSynced(todo.id);
    }

    final unsyncedBlocks = await db.getUnsyncedTimeBlocks();
    for (final block in unsyncedBlocks) {
      await _client.from('time_blocks').upsert({
        'id': block.id,
        'user_id': userId,
        'date': _formatDate(block.date),
        'label': block.label,
        'start_time': '${block.startTime}:00',
        'end_time': '${block.endTime}:00',
        'note': block.note,
        'color': block.color,
        'created_at': block.createdAt.toUtc().toIso8601String(),
        'updated_at': block.updatedAt.toUtc().toIso8601String(),
      });
      await db.markTimeBlockSynced(block.id);
    }
  }

  Future<void> _pull() async {
    final lastPull = await _getLastPullTime();
    final now = DateTime.now().toUtc();
    final since = lastPull.toIso8601String();

    final todosData = await _client
        .from('todos')
        .select()
        .gte('updated_at', since) as List;

    for (final row in todosData) {
      await db.upsertTodo(TodosCompanion(
        id: Value(row['id'] as String),
        userId: Value(row['user_id'] as String?),
        date: Value(_parseDate(row['date'] as String)),
        title: Value(row['title'] as String),
        isDone: Value(row['is_done'] as bool),
        sortOrder: Value(row['sort_order'] as int),
        createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
        updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
        syncedAt: Value(now),
      ));
    }

    final blocksData = await _client
        .from('time_blocks')
        .select()
        .gte('updated_at', since) as List;

    for (final row in blocksData) {
      await db.upsertTimeBlock(TimeBlocksCompanion(
        id: Value(row['id'] as String),
        userId: Value(row['user_id'] as String?),
        date: Value(_parseDate(row['date'] as String)),
        label: Value(row['label'] as String),
        startTime: Value(_parseTime(row['start_time'] as String)),
        endTime: Value(_parseTime(row['end_time'] as String)),
        note: Value(row['note'] as String?),
        color: Value(row['color'] as String?),
        createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
        updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
        syncedAt: Value(now),
      ));
    }

    await _setLastPullTime(now);
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _parseDate(String s) {
    final p = s.split('-');
    return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  String _parseTime(String s) {
    final parts = s.split(':');
    return '${parts[0]}:${parts[1]}';
  }

  Future<DateTime> _getLastPullTime() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_lastPullKey);
    if (ms == null) return DateTime.utc(2020, 1, 1);
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  Future<void> _setLastPullTime(DateTime t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPullKey, t.millisecondsSinceEpoch);
  }

  Future<void> clearLocalData() async {
    await db.clearAllData();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPullKey);
  }
}
