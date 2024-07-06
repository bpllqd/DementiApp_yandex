// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart'
    as _i3;
import 'package:demetiapp/core/data/datasources/remote/dio_service.dart'
    as _i11;
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart'
    as _i8;
import 'package:demetiapp/core/data/repositories/to_do_list_repository_impl.dart'
    as _i9;
import 'package:demetiapp/core/di/di.dart' as _i12;
import 'package:demetiapp/core/domain/repository/todo_list_repository.dart'
    as _i10;
import 'package:demetiapp/core/presentation/bloc/todo_list_bloc.dart' as _i7;
import 'package:demetiapp/core/utils/network_status.dart' as _i5;
import 'package:demetiapp/core/utils/utils.dart' as _i4;
import 'package:dio/dio.dart' as _i6;
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
    gh.factory<_i3.TaskLocalDatasourceImpl>(
        () => _i3.TaskLocalDatasourceImpl());
    gh.factory<_i4.MyHttpOverrides>(() => _i4.MyHttpOverrides());
    gh.lazySingleton<_i5.NetworkStatus>(() => _i5.NetworkStatus());
    gh.lazySingleton<_i6.Dio>(() => dioModule.provideDio());
    gh.singleton<_i3.TaskLocalDataSource>(() => registerModule
        .provideTaskLocalDataSource(gh<_i3.TaskLocalDatasourceImpl>()));
    gh.factory<_i7.ToDoListBloc>(() => _i7.ToDoListBloc(
          networkStatus: gh<_i5.NetworkStatus>(),
          db: gh<_i3.TaskLocalDatasourceImpl>(),
          dio: gh<_i6.Dio>(),
        ));
    gh.factory<_i8.TaskRemoteDataSourceImpl>(
        () => _i8.TaskRemoteDataSourceImpl(dio: gh<_i6.Dio>()));
    gh.singleton<_i8.TaskRemoteDataSource>(() => registerModule
        .provideTaskRemoteDataSource(gh<_i8.TaskRemoteDataSourceImpl>()));
    gh.factory<_i9.ToDoListRepositoryImpl>(() => _i9.ToDoListRepositoryImpl(
          db: gh<_i3.TaskLocalDataSource>(),
          api: gh<_i8.TaskRemoteDataSource>(),
          networkStatus: gh<_i5.NetworkStatus>(),
        ));
    gh.singleton<_i10.ToDoListRepository>(() => registerModule
        .provideToDoListRepository(gh<_i9.ToDoListRepositoryImpl>()));
    return this;
  }
}

class _$DioModule extends _i11.DioModule {}

class _$RegisterModule extends _i12.RegisterModule {}
