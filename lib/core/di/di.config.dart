// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:demetiapp/core/data/datasources/local/database_helper.dart'
    as _i3;
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart'
    as _i8;
import 'package:demetiapp/core/data/datasources/remote/dio_service.dart'
    as _i12;
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart'
    as _i7;
import 'package:demetiapp/core/data/repositories/to_do_list_repository_impl.dart'
    as _i10;
import 'package:demetiapp/core/di/di.dart' as _i13;
import 'package:demetiapp/core/domain/repository/todo_list_repository.dart'
    as _i11;
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart' as _i9;
import 'package:demetiapp/core/utils/network_status.dart' as _i6;
import 'package:demetiapp/core/utils/utils.dart' as _i4;
import 'package:dio/dio.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dioModule = _$DioModule();
    final registerModule = _$RegisterModule();
    gh.factory<_i3.DatabaseHelper>(() => _i3.DatabaseHelper());
    gh.factory<_i4.MyHttpOverrides>(() => _i4.MyHttpOverrides());
    gh.lazySingleton<_i5.Dio>(() => dioModule.provideDio());
    gh.lazySingleton<_i6.NetworkStatus>(() => _i6.NetworkStatus());
    gh.factory<_i7.TaskRemoteDataSourceImpl>(
        () => _i7.TaskRemoteDataSourceImpl(dio: gh<_i5.Dio>()));
    gh.factory<_i8.TaskLocalDatasourceImpl>(() =>
        _i8.TaskLocalDatasourceImpl(databaseHelper: gh<_i3.DatabaseHelper>()));
    gh.singleton<_i7.TaskRemoteDataSource>(() => registerModule
        .provideTaskRemoteDataSource(gh<_i7.TaskRemoteDataSourceImpl>()));
    gh.singleton<_i8.TaskLocalDataSource>(() => registerModule
        .provideTaskLocalDataSource(gh<_i8.TaskLocalDatasourceImpl>()));
    gh.factory<_i9.ToDoListBloc>(() => _i9.ToDoListBloc(
          networkStatus: gh<_i6.NetworkStatus>(),
          db: gh<_i8.TaskLocalDatasourceImpl>(),
          dio: gh<_i5.Dio>(),
        ));
    gh.factory<_i10.ToDoListRepositoryImpl>(() => _i10.ToDoListRepositoryImpl(
          db: gh<_i8.TaskLocalDataSource>(),
          api: gh<_i7.TaskRemoteDataSource>(),
          networkStatus: gh<_i6.NetworkStatus>(),
        ));
    gh.singleton<_i11.ToDoListRepository>(() => registerModule
        .provideToDoListRepository(gh<_i10.ToDoListRepositoryImpl>()));
    return this;
  }
}

class _$DioModule extends _i12.DioModule {}

class _$RegisterModule extends _i13.RegisterModule {}
