import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo/data.dart';
import 'package:todo/edit.dart';

const taskBoxName = 'tasks';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskData>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: primaryContainerColor));
  runApp(const MyApp());
}

const primaryColor = Color(0xff794CFF);
const primaryContainerColor = Color(0xff5C0AFF);
const secondaryTextColor = Color(0xffAFBED0);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xff1D2830);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          fontFamily: 'PrimaryFont',
          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
            labelStyle: TextStyle(color: secondaryTextColor),
            prefixIconColor: secondaryTextColor,
          ),
          colorScheme: const ColorScheme.light(
              primary: primaryColor,
              primaryContainer: primaryContainerColor,
              background: Color(0xffF3F5F8),
              onSurface: primaryTextColor,
              onBackground: primaryTextColor,
              onPrimary: Colors.white,
              secondary: primaryColor,
              onSecondary: Colors.white)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskData>(taskBoxName);
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
              builder: (context) => EditTaskScreen(
                task: TaskData(),
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
      body: SafeArea(
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
                      child: const TextField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.search),
                              label: Text('Search tasks...'))),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Box<TaskData>>(
                valueListenable: box.listenable(),
                builder: (context, value, child) {
                  return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: box.values.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Today',
                                      style: themeData.textTheme.titleLarge!
                                          .copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 60,
                                    height: 4,
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(1.5)),
                                  )
                                ],
                              ),
                              MaterialButton(
                                elevation: 0,
                                textColor: secondaryTextColor,
                                color: const Color(0xffEAEFF5),
                                onPressed: () {},
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
                          final taskData = box.values.toList()[index];
                          return TaskItem(task: taskData);
                        }
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskItem extends StatefulWidget {
  static const double height = 84;

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
            builder: (context) => EditTaskScreen(task: widget.task)));
      }),
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
                    fontSize: 20,
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

class CustomCheckBox extends StatelessWidget {
  final bool value;
  final GestureTapCallback onTap;
  const CustomCheckBox({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              !value ? Border.all(width: 2, color: secondaryTextColor) : null,
          color: value ? primaryColor : null,
        ),
        child: value
            ? Icon(
                CupertinoIcons.check_mark,
                color: themeData.colorScheme.onPrimary,
                size: 12,
              )
            : null,
      ),
    );
  }
}
