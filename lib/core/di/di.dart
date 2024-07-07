import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart';
import 'package:demetiapp/core/data/repositories/to_do_list_repository_impl.dart';
import 'package:demetiapp/core/domain/repository/todo_list_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

final getIt = GetIt.I;

@injectableInit
Future<void> configureDependencies() async {
  getIt.init();
}

@module
abstract class RegisterModule {
  @singleton
  TaskLocalDataSource provideTaskLocalDataSource(
    TaskLocalDatasourceImpl dataSource,
  ) =>
      dataSource;

  @singleton
  TaskRemoteDataSource provideTaskRemoteDataSource(
    TaskRemoteDataSourceImpl dataSource,
  ) =>
      dataSource;

  @singleton
  ToDoListRepository provideToDoListRepository(
    ToDoListRepositoryImpl repository,
  ) =>
      repository;
}
