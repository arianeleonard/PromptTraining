enum TaskStatus { pending, inProgress, complete, failed }

class TaskItem {
  final String id;
  final String title;
  final TaskStatus status;
  final double progress; // 0..1
  final String? details;
  const TaskItem({
    required this.id,
    required this.title,
    this.status = TaskStatus.pending,
    this.progress = 0.0,
    this.details,
  });
}