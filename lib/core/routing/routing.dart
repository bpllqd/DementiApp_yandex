import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/features/todo_create/presentation/screens/todo_create_screen.dart';
import 'package:demetiapp/features/todo_list/presentation/screens/todo_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> dementiappRoutes = <RouteBase>[
  GoRoute(
    path: '/',
    builder: (BuildContext context, GoRouterState state) =>
        const ToDoListScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: 'add_new',
        builder: (BuildContext context, GoRouterState state) {
          final TaskEntity? task = state.extra as TaskEntity?;
          return ToDoCreateScreen(task: task);
        },
      ),
    ],
  ),
];
