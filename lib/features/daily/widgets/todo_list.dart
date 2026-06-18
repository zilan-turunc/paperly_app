import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/local/database.dart';
import '../daily_provider.dart';
import 'todo_item.dart';
import 'add_todo_sheet.dart';

class TodoList extends ConsumerWidget {
  final DateTime date;
  const TodoList({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosProvider(date));

    return todosAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('Error: $e'),
      data: (todos) => _TodoListContent(date: date, todos: todos),
    );
  }
}

class _TodoListContent extends ConsumerStatefulWidget {
  final DateTime date;
  final List<Todo> todos;
  const _TodoListContent({required this.date, required this.todos});

  @override
  ConsumerState<_TodoListContent> createState() => _TodoListContentState();
}

class _TodoListContentState extends ConsumerState<_TodoListContent> {
  bool _completedExpanded = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(dailyNotifierProvider.notifier);
    final pending = widget.todos.where((t) => !t.isDone).toList();
    final done = widget.todos.where((t) => t.isDone).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          label: 'To Do',
          onAdd: () => showAddTodoSheet(context, widget.date),
        ),
        if (widget.todos.isEmpty)
          const _PlaceholderText('Nothing yet — add something')
        else ...[
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final ids = pending.map((t) => t.id).toList();
              final moved = ids.removeAt(oldIndex);
              ids.insert(newIndex, moved);
              notifier.reorderTodos(ids);
            },
            children: pending
                .map((t) => TodoItem(key: ValueKey(t.id), todo: t))
                .toList(),
          ),
          if (done.isNotEmpty) ...[
            const Divider(height: 8),
            GestureDetector(
              onTap: () => setState(() => _completedExpanded = !_completedExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      _completedExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${done.length} completed',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            if (_completedExpanded)
              ...done.map((t) => TodoItem(key: ValueKey(t.id), todo: t)),
          ],
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final VoidCallback onAdd;
  const _SectionHeader({required this.label, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
          GestureDetector(
            onTap: onAdd,
            child: const Icon(Icons.add, size: 20, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderText extends StatelessWidget {
  final String text;
  const _PlaceholderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textPlaceholder)),
    );
  }
}
