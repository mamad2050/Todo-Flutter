part of 'edit_task_cubit.dart';

@immutable
abstract class EditTaskState {
  final TaskData task;

  const EditTaskState({required this.task});
}

class EditTaskInitial extends EditTaskState {
  const EditTaskInitial({required super.task});
}

class EditTaskPriorityChanged extends EditTaskState {
  const EditTaskPriorityChanged({required super.task});
}
