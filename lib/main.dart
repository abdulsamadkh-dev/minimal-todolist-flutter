import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/data/data.dart';
import 'package:todo_list/data/repo/repository.dart';
import 'package:todo_list/screens/home/bloc/task_list_bloc.dart';
import 'package:todo_list/screens/home/home.dart';
import 'package:todo_list/utils/app_constatns.dart';

import 'data/source/hive_task_source.dart';

const taskBoxName = 'tasks';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskEntity>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: onPrimaryFixedVariant));
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider<Repository<TaskEntity>>(
          create: (context) => Repository<TaskEntity>(
              localDataSource: HiveTaskDataSource(Hive.box(taskBoxName)))),
      BlocProvider<TaskListBloc>(
        create: (context) =>
            TaskListBloc(context.read<Repository<TaskEntity>>()),
      ),
    ], child: const TodoListApp()),
  );
}

class TodoListApp extends StatelessWidget {
  const TodoListApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const primaryTextColor = Color(0xff1D2830);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MINIMAL TODO LIST - FLUTTER',
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(
            const TextTheme(
                headlineSmall: TextStyle(fontWeight: FontWeight.bold)),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(color: secondaryTextColor),
            border: InputBorder.none,
            iconColor: secondaryTextColor,
          ),
          colorScheme: const ColorScheme.light(
            primary: primaryColor,
            onPrimaryFixedVariant: onPrimaryFixedVariant,
            surface: Color(0xffF3F5F8),
            onSurface: primaryTextColor,
            onPrimary: Colors.white,
            secondary: primaryColor,
            onSecondary: Colors.white,
          )),
      home: HomeScreen(),
    );
  }
}
