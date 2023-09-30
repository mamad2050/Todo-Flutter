part of 'task_list_bloc.dart';

@immutable
abstract class TaskListEvent {}

class TaskListStarted extends TaskListEvent {}

class TaskListSearch extends TaskListEvent {
  final String searchKeyWord;

  TaskListSearch(this.searchKeyWord);
}

class TaskListDeleteAll extends TaskListEvent {}
