class Task {
  String name = '';
  bool isCompleted = false;
  Priority priority = Priority.low;
}

enum Priority { low, normal, high }
