import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/database.dart';
import '../../data/remote/supabase_sync.dart';

const _uuid = Uuid();

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime.utc(now.year, now.month, now.day);
});

final todosProvider = StreamProvider.family<List<Todo>, DateTime>((ref, date) {
  final db = ref.watch(databaseProvider);
  return db.watchTodosForDate(date);
});

final timeBlocksProvider =
    StreamProvider.family<List<TimeBlock>, DateTime>((ref, date) {
  final db = ref.watch(databaseProvider);
  return db.watchTimeBlocksForDate(date);
});

class DailyNotifier extends Notifier<void> {
  AppDatabase get _db => ref.read(databaseProvider);
  SupabaseSync get _sync => ref.read(syncServiceProvider);
  Timer? _debounce;

  @override
  void build() {}

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
      _sync.sync().then((_) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
      }).catchError((_) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
      });
    });
  }

  // ── Todos ──────────────────────────────────────────────────────────────────

  Future<void> addTodo(DateTime date, String title) async {
    final existing = await _db.getTodosForDate(date);
    final maxOrder = existing.isEmpty
        ? 0
        : existing.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    final now = DateTime.now();
    await _db.insertTodo(TodosCompanion.insert(
      id: _uuid.v4(),
      date: DateTime.utc(date.year, date.month, date.day),
      title: title,
      sortOrder: maxOrder,
      createdAt: now,
      updatedAt: now,
    ));
    _scheduleSync();
  }

  Future<void> toggleTodo(Todo todo) async {
    await _db.updateTodo(TodosCompanion(
      id: Value(todo.id),
      isDone: Value(!todo.isDone),
      updatedAt: Value(DateTime.now()),
    ));
    _scheduleSync();
  }

  Future<void> deleteTodo(String id) async {
    await _db.deleteTodo(id);
    _scheduleSync();
  }

  Future<void> reorderTodos(List<String> orderedIds) async {
    await _db.reorderTodos(orderedIds);
    _scheduleSync();
  }

  // ── Time blocks ────────────────────────────────────────────────────────────

  Future<void> addTimeBlock({
    required DateTime date,
    required String label,
    required String startTime,
    required String endTime,
    String? note,
    String? color,
  }) async {
    final now = DateTime.now();
    await _db.insertTimeBlock(TimeBlocksCompanion.insert(
      id: _uuid.v4(),
      date: DateTime.utc(date.year, date.month, date.day),
      label: label,
      startTime: startTime,
      endTime: endTime,
      note: Value(note),
      color: Value(color),
      createdAt: now,
      updatedAt: now,
    ));
    _scheduleSync();
  }

  Future<void> updateTimeBlock({
    required String id,
    required String label,
    required String startTime,
    required String endTime,
    String? note,
    String? color,
  }) async {
    await _db.updateTimeBlock(TimeBlocksCompanion(
      id: Value(id),
      label: Value(label),
      startTime: Value(startTime),
      endTime: Value(endTime),
      note: Value(note),
      color: Value(color),
      updatedAt: Value(DateTime.now()),
    ));
    _scheduleSync();
  }

  Future<void> deleteTimeBlock(String id) async {
    await _db.deleteTimeBlock(id);
    _scheduleSync();
  }
}

final dailyNotifierProvider =
    NotifierProvider<DailyNotifier, void>(DailyNotifier.new);
