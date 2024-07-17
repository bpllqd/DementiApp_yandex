import 'package:demetiapp/features/todo_create/presentation/screens/todo_create_screen.dart';
import 'package:demetiapp/features/todo_list/presentation/screens/todo_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> dementiappRoutes = <RouteBase>[
  GoRoute(
    path: '/',
    pageBuilder: (context, state) {
      return CustomTransitionPage(
        transitionDuration: const Duration(seconds: 2),
        key: state.pageKey,
        child: const ToDoListScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(
              curve: Curves.easeInOutCirc,
            ).animate(animation),
            child: child,
          );
        },
      );
    },
    // builder: (BuildContext context, GoRouterState state) =>
    //     const ToDoListScreen(),
    routes: <RouteBase>[
      GoRoute(
        path: 'add_new',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            transitionDuration: const Duration(seconds: 2),
            key: state.pageKey,
            child: const ToDoCreateScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(
                  curve: Curves.easeInOutCirc,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
        // builder: (BuildContext context, GoRouterState state) {
        //   return const ToDoCreateScreen();
        // },
      ),
    ],
  ),
];
