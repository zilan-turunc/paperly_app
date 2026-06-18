import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Todos extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TimeBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get label => text()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get note => text().nullable()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Todos, TimeBlocks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Todos ──────────────────────────────────────────────────────────────────

  Stream<List<Todo>> watchTodosForDate(DateTime date) {
    final day = _dayOnly(date);
    return (select(todos)
          ..where((t) => t.date.equals(day))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
        .watch();
  }

  Future<List<Todo>> getTodosForDate(DateTime date) {
    final day = _dayOnly(date);
    return (select(todos)
          ..where((t) => t.date.equals(day))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> insertTodo(TodosCompanion todo) => into(todos).insert(todo);

  Future<void> updateTodo(TodosCompanion todo) =>
      (update(todos)..where((t) => t.id.equals(todo.id.value))).write(todo);

  Future<void> deleteTodo(String id) =>
      (delete(todos)..where((t) => t.id.equals(id))).go();

  Future<void> reorderTodos(List<String> orderedIds) {
    return transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(todos)..where((t) => t.id.equals(orderedIds[i]))).write(
          TodosCompanion(sortOrder: Value(i), updatedAt: Value(DateTime.now())),
        );
      }
    });
  }

  // ── TimeBlocks ─────────────────────────────────────────────────────────────

  Stream<List<TimeBlock>> watchTimeBlocksForDate(DateTime date) {
    final day = _dayOnly(date);
    return (select(timeBlocks)
          ..where((t) => t.date.equals(day))
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .watch();
  }

  Future<List<TimeBlock>> getTimeBlocksForDate(DateTime date) {
    final day = _dayOnly(date);
    return (select(timeBlocks)
          ..where((t) => t.date.equals(day))
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();
  }

  Future<void> insertTimeBlock(TimeBlocksCompanion block) =>
      into(timeBlocks).insert(block);

  Future<void> updateTimeBlock(TimeBlocksCompanion block) =>
      (update(timeBlocks)..where((t) => t.id.equals(block.id.value)))
          .write(block);

  Future<void> deleteTimeBlock(String id) =>
      (delete(timeBlocks)..where((t) => t.id.equals(id))).go();

  // ── Sync helpers ───────────────────────────────────────────────────────────

  Future<List<Todo>> getUnsyncedTodos() =>
      (select(todos)..where((t) => t.syncedAt.isNull())).get();

  Future<List<TimeBlock>> getUnsyncedTimeBlocks() =>
      (select(timeBlocks)..where((t) => t.syncedAt.isNull())).get();

  Future<void> markTodoSynced(String id) =>
      (update(todos)..where((t) => t.id.equals(id)))
          .write(TodosCompanion(syncedAt: Value(DateTime.now())));

  Future<void> markTimeBlockSynced(String id) =>
      (update(timeBlocks)..where((t) => t.id.equals(id)))
          .write(TimeBlocksCompanion(syncedAt: Value(DateTime.now())));

  Future<void> upsertTodo(TodosCompanion todo) =>
      into(todos).insertOnConflictUpdate(todo);

  Future<void> upsertTimeBlock(TimeBlocksCompanion block) =>
      into(timeBlocks).insertOnConflictUpdate(block);
}

DateTime _dayOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'paperly.db'));
    return NativeDatabase.createInBackground(file);
  });
}
