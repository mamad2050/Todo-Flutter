import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/repo/repository.dart';
import 'package:todo/main.dart';
import 'package:todo/screens/edit/cubit/edit_task_cubit.dart';
import 'package:todo/screens/edit/edit.dart';
import 'package:todo/screens/home/bloc/task_list_bloc.dart';
import 'package:todo/widgets.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 160,
        height: 46,
        decoration: BoxDecoration(
            color: primaryColor, borderRadius: BorderRadius.circular(4)),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BlocProvider<EditTaskCubit>(
                create: (context) => EditTaskCubit(
                    TaskData(), context.read<Repository<TaskData>>()),
                child: const EditTaskScreen(),
              ),
            ));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add New Task',
                style: TextStyle(
                  color: themeData.colorScheme.onPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.2)),
                child: Icon(
                  CupertinoIcons.add,
                  color: themeData.colorScheme.onPrimary,
                  size: 16,
                ),
              )
            ],
          ),
        ),
      ),
      body: BlocProvider<TaskListBloc>(
        create: (context) => TaskListBloc(context.read<Repository<TaskData>>()),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 102,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  themeData.colorScheme.primary,
                  themeData.colorScheme.primaryContainer
                ])),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'To Do List',
                            style: themeData.textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: themeData.colorScheme.onPrimary),
                          ),
                          Icon(
                            CupertinoIcons.share,
                            color: themeData.colorScheme.onPrimary,
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 38,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19),
                            color: themeData.colorScheme.onPrimary,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20)
                            ]),
                        child: Builder(builder: (context) {
                          return TextField(
                              onChanged: (value) {
                                context
                                    .read<TaskListBloc>()
                                    .add(TaskListSearch(value));
                              },
                              controller: controller,
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(CupertinoIcons.search),
                                  label: Text('Search tasks...')));
                        }),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Consumer<Repository<TaskData>>(
                    builder: (context, value, child) {
                  context.read<TaskListBloc>().add(TaskListStarted());
                  return BlocBuilder<TaskListBloc, TaskListState>(
                    builder: (context, state) {
                      if (state is TaskListSuccess) {
                        return TaskList(
                            items: state.items, themeData: themeData);
                      } else if (state is TaskListEmpty) {
                        return const EmptyState();
                      } else if (state is TaskListLoading ||
                          state is TaskListInitial) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TaskListError) {
                        return Center(child: Text(state.errorMessage));
                      } else {
                        throw Exception('state is not valid.');
                      }
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.items,
    required this.themeData,
  });

  final List<TaskData> items;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today',
                        style: themeData.textTheme.titleLarge!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(1.5)),
                    )
                  ],
                ),
                MaterialButton(
                  elevation: 0,
                  textColor: secondaryTextColor,
                  color: const Color(0xffEAEFF5),
                  onPressed: () {
                    context.read<TaskListBloc>().add(TaskListDeleteAll());
                  },
                  child: const Row(
                    children: [
                      Text('Delete All'),
                      SizedBox(width: 4),
                      Icon(CupertinoIcons.delete_solid, size: 18),
                    ],
                  ),
                )
              ],
            );
          } else {
            final taskData = items[index - 1];
            return TaskItem(task: taskData);
          }
        });
  }
}

class TaskItem extends StatefulWidget {
  static const double height = 74;

  const TaskItem({
    super.key,
    required this.task,
  });

  final TaskData task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color priorityColor;

    switch (widget.task.priority) {
      case Priority.low:
        priorityColor = Colors.cyan;
        break;
      case Priority.normal:
        priorityColor = Colors.orange;
        break;
      case Priority.high:
        priorityColor = Colors.red;
        break;
    }
    return InkWell(
      onTap: (() {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BlocProvider<EditTaskCubit>(
                  create: (context) => EditTaskCubit(
                      widget.task, context.read<Repository<TaskData>>()),
                  child: const EditTaskScreen(),
                )));
      }),
      onLongPress: () {
        widget.task.delete();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 16),
        height: TaskItem.height,
        decoration: BoxDecoration(
          color: themeData.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CustomCheckBox(
              value: widget.task.isCompleted,
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                });
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 18,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 5,
              height: TaskItem.height,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  color: priorityColor),
            )
          ],
        ),
      ),
    );
  }
}
