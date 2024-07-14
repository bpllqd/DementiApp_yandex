import 'package:demetiapp/core/routing/routing.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/core/theme/theme.dart';
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:demetiapp/generated/l10n.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ToDoListBloc()..add(GetTasksEvent()),
        ),
      ],
      child: RoutingWrapper(),
    );
  }
}

class RoutingWrapper extends StatelessWidget {
  RoutingWrapper({super.key});

  final GoRouter _router = GoRouter(
    routes: dementiappRoutes,
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'DementiApp',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: lightTheme(),
      darkTheme: darkTheme(),
    );
  }
}
