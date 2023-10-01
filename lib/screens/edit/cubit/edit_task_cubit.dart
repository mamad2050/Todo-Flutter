import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/repo/repository.dart';

part 'edit_task_state.dart';

class EditTaskCubit extends Cubit<EditTaskState> {
  final TaskData _task;
  final Repository<TaskData> repository;

  EditTaskCubit(
    this._task,
    this.repository,
  ) : super(EditTaskInitial(task: _task));

  void onSaveChangesClick() {
    repository.createOrUpdate(_task);
  }

  void onTextChanged(String newText) {
    _task.name = newText;
  }

  void onPriorityChnaged(Priority newPriority) {
    _task.priority = newPriority;
    emit(EditTaskPriorityChanged(task: _task));
  }
}
