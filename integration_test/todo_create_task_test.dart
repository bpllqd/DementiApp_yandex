import 'dart:io';

import 'package:demetiapp/core/di/di.dart';
import 'package:demetiapp/core/utils/network_status.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/features/todo_create/presentation/screens/todo_create_screen.dart';
import 'package:demetiapp/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await configureDependencies();
    await initializeDateFormatting('ru_RU', null);
    final networkStatus = GetIt.instance.get<NetworkStatus>();
    await networkStatus.init();
    HttpOverrides.global = MyHttpOverrides();
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('onTap по кнопке создания таски', () {
    testWidgets(
        'произойдет навигация на экран создания задачи с пустыми полями формы',
        (widgetTester) async {
      //arrange
      await widgetTester.pumpWidget(
        const MyApp(),
      );

      await widgetTester.pumpAndSettle();

      //act
      final button = find.byKey(const ValueKey('FloatingAddNewButton'));
      await widgetTester.tap(button);
      await widgetTester.pumpAndSettle();

      // Assert
      expect(find.byType(ToDoCreateScreen), findsOneWidget);
    });
  });
}
