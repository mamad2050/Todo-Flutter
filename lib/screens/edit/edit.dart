import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/repo/repository.dart';
import 'package:todo/main.dart';
import 'package:todo/screens/edit/cubit/edit_task_cubit.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(
        text: context.read<EditTaskCubit>().state.task.name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: themeData.colorScheme.surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: 160,
        height: 46,
        decoration: BoxDecoration(
            color: primaryColor, borderRadius: BorderRadius.circular(4)),
        child: InkWell(
          onTap: () {
            context.read<EditTaskCubit>().onSaveChangesClick();

            Navigator.of(context).pop();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Save Changes',
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
                  CupertinoIcons.check_mark,
                  color: themeData.colorScheme.onPrimary,
                  size: 14,
                ),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
          elevation: 0,
          foregroundColor: themeData.colorScheme.onSurface,
          backgroundColor: themeData.colorScheme.surface,
          title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BlocBuilder<EditTaskCubit, EditTaskState>(
              builder: (context, state) {
                final priority = state.task.priority;
                return Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                        flex: 1,
                        child: PriorityRadioButton(
                          label: 'High',
                          color: Colors.red,
                          isSelected: priority == Priority.high,
                          ontap: () {
                            context
                                .read<EditTaskCubit>()
                                .onPriorityChnaged(Priority.high);
                          },
                        )),
                    const SizedBox(width: 8),
                    Flexible(
                        flex: 1,
                        child: PriorityRadioButton(
                          label: 'Normal',
                          color: Colors.orange,
                          isSelected: priority == Priority.normal,
                          ontap: () {
                            context
                                .read<EditTaskCubit>()
                                .onPriorityChnaged(Priority.normal);
                          },
                        )),
                    const SizedBox(width: 8),
                    Flexible(
                        flex: 1,
                        child: PriorityRadioButton(
                          label: 'Low',
                          color: Colors.cyan,
                          isSelected: priority == Priority.low,
                          ontap: () {
                            context
                                .read<EditTaskCubit>()
                                .onPriorityChnaged(Priority.low);
                          },
                        )),
                  ],
                );
              },
            ),
            TextField(
              controller: _controller,
              onChanged: (value) {
                context.read<EditTaskCubit>().onTextChanged(value);
              },
              decoration: InputDecoration(
                label: Text('Add a task for today...',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .apply(fontSizeFactor: 1.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriorityRadioButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final GestureTapCallback ontap;

  const PriorityRadioButton(
      {super.key,
      required this.label,
      required this.color,
      required this.isSelected,
      required this.ontap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                width: 2,
                color: isSelected
                    ? color.withOpacity(0.5)
                    : secondaryTextColor.withOpacity(0.2))),
        child: Stack(children: [
          Center(child: Text(label)),
          Positioned(
            right: 8,
            bottom: 0,
            top: 0,
            child: Center(
              child: PriorityCheckBox(
                value: isSelected,
                color: color,
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class PriorityCheckBox extends StatelessWidget {
  final bool value;
  final Color color;

  const PriorityCheckBox({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color,
      ),
      child: value
          ? Icon(
              CupertinoIcons.check_mark,
              color: themeData.colorScheme.onPrimary,
              size: 12,
            )
          : null,
    );
  }
}
