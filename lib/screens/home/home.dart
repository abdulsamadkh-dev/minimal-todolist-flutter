import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/data/data.dart';
import 'package:todo_list/data/repo/repository.dart';
import 'package:todo_list/screens/edit/cubit/edit_task_cubit.dart';
import 'package:todo_list/screens/edit/edit.dart';
import 'package:todo_list/screens/home/bloc/task_list_bloc.dart';
import 'package:todo_list/utils/app_constatns.dart';
import 'package:todo_list/widgets.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => BlocProvider<EditTaskCubit>(
                    create: (context) => EditTaskCubit(
                        TaskEntity(), context.read<Repository<TaskEntity>>()),
                    child: const EditTaskScreen(),
                  )));
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        label: const Row(
          children: [
            Text('Add New Task'),
            SizedBox(
              width: 3,
            ),
            Icon(
              CupertinoIcons.add_circled,
              size: 20,
            ),
          ],
        ),
      ),
      body: BlocProvider<TaskListBloc>(
        create: (context) => BlocProvider.of<TaskListBloc>(context),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  themeData.colorScheme.primary,
                  themeData.colorScheme.primary,
                ])),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Text(
                              'To-Do List',
                              style: themeData.textTheme.headlineSmall!.apply(
                                color: themeData.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          // Icon(
                          //   CupertinoIcons.share,
                          //   color: themeData.colorScheme.onPrimary,
                          // ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19),
                            color: themeData.colorScheme.onPrimary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                              )
                            ]),
                        child: TextField(
                          onChanged: (value) {
                            BlocProvider.of<TaskListBloc>(context)
                                .add(TaskListSearch(value));
                          },
                          controller: controller,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(CupertinoIcons.search),
                              //  hintText: 'Search tasks...',
                              label: Text('Search Tasks')),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Consumer<Repository<TaskEntity>>(
                  builder: (context, model, child) {
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
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        } else if (state is TaskListError) {
                          return Center(
                            child: Text(state.errorMessage),
                          );
                        } else {
                          throw Exception('State is invalid!');
                        }
                      },
                    );
                  },
                ),
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

  final List<TaskEntity> items;
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
                    const Text(
                      'Today',
                    ),
                    Container(
                      width: 70,
                      height: 3,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    )
                  ],
                ),
                MaterialButton(
                    color: const Color(0xffEAEFF5),
                    textColor: secondaryTextColor,
                    elevation: 0,
                    onPressed: () {
                      _showDeleteAllConfirmationDialog(context);
                    },
                    child: const Row(
                      children: [
                        Text('Delete All'),
                        SizedBox(
                          width: 4,
                        ),
                        Icon(
                          CupertinoIcons.delete_solid,
                          size: 18,
                        ),
                      ],
                    )),
              ],
            );
          } else {
            final TaskEntity task = items[index - 1];
            return TaskItem(task: task);
          }
        });
  }
}

class TaskItem extends StatefulWidget {
  static const double height = 74;
  static const double borderRadius = 8;

  const TaskItem({
    super.key,
    required this.task,
  });

  final TaskEntity task;

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
        priorityColor = lowPriority;
      case Priority.normal:
        priorityColor = normalPriority;
      case Priority.high:
        priorityColor = highPriority;
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => BlocProvider<EditTaskCubit>(
                  create: (context) => EditTaskCubit(
                      widget.task, context.read<Repository<TaskEntity>>()),
                  child: const EditTaskScreen(),
                )));
      },
      onLongPress: () {
        _showDeleteConfirmationDialog(context, widget.task);
      },
      child: Container(
        height: TaskItem.height,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TaskItem.borderRadius),
            color: themeData.colorScheme.surface,
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.grey.withOpacity(0.2))
            ]),
        child: Row(
          children: [
            Container(
              width: 15,
              height: TaskItem.height,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(TaskItem.borderRadius),
                  bottomLeft: Radius.circular(TaskItem.borderRadius),
                ),
              ),
              child: Center(
                child: Text(
                  widget.task.priority == Priority.low
                      ? 'P3'
                      : widget.task.priority == Priority.normal
                          ? 'P2'
                          : 'P1',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 4, // Reduced the padding here
            ),
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
            const SizedBox(
              width: 8, // Reduced the padding here
            ),
            MyCheckBox(
              value: widget.task.isCompleted,
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                });
              },
            ),
            const SizedBox(
              width: 8, // Added padding to the right edge
            ),
          ],
        ),
      ),
    );
  }
}

void _showDeleteConfirmationDialog(BuildContext context, TaskEntity task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without deleting
            },
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () {
              task.delete(); // Delete the task

              // After task.delete(), add this line to refresh the list
              context.read<TaskListBloc>().add(TaskListStarted());

              // Provide feedback to the user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Task deleted successfully"),
                ),
              );

              // Close the dialog
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _showDeleteAllConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete All Tasks"),
        content: const Text(
            "Are you sure you want to delete all tasks? This action cannot be undone!"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              // Close the dialog without deleting anything
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("Delete All"),
            onPressed: () {
              // Trigger the action to delete all tasks
              context.read<TaskListBloc>().add(TaskListDeletAll());

              // Provide feedback to the user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All tasks deleted successfully"),
                ),
              );

              // Close the dialog
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
