import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/repo/repository.dart';

part 'task_list_event.dart';
part 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final Repository<TaskData> repository;
  TaskListBloc(this.repository) : super(TaskListInitial()) {
    on<TaskListEvent>((event, emit) async {
      if (event is TaskListStarted || event is TaskListSearch) {
        final String searchKeyWord;
        emit(TaskListLoading());
        if (event is TaskListSearch) {
          searchKeyWord = event.searchKeyWord;
        } else {
          searchKeyWord = '';
        }

        try {
          final items = await repository.getAll(searchKeyword: searchKeyWord);
          if (items.isNotEmpty) {
            emit(TaskListSuccess(items));
          } else {
            emit(TaskListEmpty());
          }
        } catch (e) {
          emit(TaskListError('Unknown Error.'));
        }
      } else if (event is TaskListDeleteAll) {
        await repository.deleteAll();
        emit(TaskListEmpty());
      }
    });
  }
}
