class PlannedTodo {
  final String title;
  const PlannedTodo({required this.title});
}

class PlannedBlock {
  final String label;
  final String startTime;
  final String endTime;
  final String? note;
  final String color;
  const PlannedBlock({
    required this.label,
    required this.startTime,
    required this.endTime,
    this.note,
    required this.color,
  });
}

class PlanResult {
  final List<PlannedTodo> todos;
  final List<PlannedBlock> timeBlocks;
  const PlanResult({required this.todos, required this.timeBlocks});

  bool get isEmpty => todos.isEmpty && timeBlocks.isEmpty;
}
