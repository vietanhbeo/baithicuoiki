  import 'package:flutter/material.dart';
  import 'view/login_screen.dart';
  import 'view/task_list_screen.dart';
  import 'view/register_screen.dart';

  void main() {
    runApp(MyApp());
  }

  class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: "Task Manager",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: "/login",
        routes: {
          "/login": (context) => LoginScreen(),
          "/register": (context) => RegisterScreen(),
          "/tasks": (context) => TaskListScreen(),
        },
      );
    }
  }
