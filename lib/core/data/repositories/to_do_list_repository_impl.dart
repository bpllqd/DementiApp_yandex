import 'dart:io' show Platform;
import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart';
import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:demetiapp/core/data/models/task_local_model.dart';
import 'package:demetiapp/core/data/models/task_mapper.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/domain/repository/todo_list_repository.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/error/failure.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ToDoListRepositoryImpl implements ToDoListRepository {
  final TaskLocalDataSource _db;
  final TaskRemoteDataSource _api;

  ToDoListRepositoryImpl({
    required TaskLocalDataSource db,
    required TaskRemoteDataSource api,
  })  : _db = db,
        _api = api;

  /// Получает user's id
  Future<String> getId() async {
    String id = '';
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      id = iosDeviceInfo.identifierForVendor ?? '';
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      id = androidDeviceInfo.id;
    } else {
      return 'user0';
    }
    return id;
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getAllTasks() async {
    try {
      final TaskApiModelWithRevision apiResult = await _api.getAllTasks();
      DementiappLogger.infoLog(
        'REPO:getAllTasks - got tasks and revision from api',
      );

      _db.updateLocalRevision(apiResult.apiRevision);
      DementiappLogger.infoLog('REPO:getAllTask - updated local revision');

      final TaskLocalModelWithRevision localResult =
          await _db.getAllTasksFromCache();
      DementiappLogger.infoLog('REPO:getAllTasks - got all tasks from local');

      final List<TaskApiModel> tasksToApi =
          TaskMapper.toApiModelList(localResult.listTasks);

      await _api.updateAllTasks(tasksToApi, apiResult.apiRevision);
      DementiappLogger.infoLog('REPO:getAllTasks - updated all in api');

      return Right(
        TaskMapper.toEntityListFromLocal(localResult.listTasks),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAllTasks(
    List<TaskEntity> tasks,
  ) async {
    try {
      final List<TaskLocalModel> tasksToLocal =
          TaskMapper.toLocalModelListFromListEntity(tasks);

      await _db.updateAllTasksToCache(tasksToLocal);
      DementiappLogger.infoLog('REPO:updateAllTasks - updated in local');
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(TaskEntity task) async {
    try {
      final TaskLocalModel taskToLocal = TaskLocalModel.fromEntity(task);

      await _db.deleteExactTaskFromCache(taskToLocal);
      DementiappLogger.infoLog('REPO:deleteTask - deleted from local');

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getExactTask(TaskEntity task) async {
    try {
      final TaskLocalModel taskToLocal = TaskLocalModel.fromEntity(task);

      final TaskLocalModelWithRevision resultLocal =
          await _db.getExactTaskFromCache(taskToLocal);
      DementiappLogger.infoLog("REPO:getExactTask - got task from local");
      final List<TaskEntity> localTaskEntities =
          TaskMapper.toEntityListFromLocal(resultLocal.listTasks);

      return Right(localTaskEntities[0]);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createTask(TaskEntity task) async {
    task = task.copyWith(lastUpdatedBy: await getId());
    DementiappLogger.infoLog('REPO:createTask - task: $task');
    try {
      final TaskLocalModel taskToLocal = TaskLocalModel.fromEntity(task);
      await _db.createTaskToCache(taskToLocal);

      DementiappLogger.infoLog(
        'REPO:createTask - created to Local!',
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editTask(
    TaskEntity oldTask,
    TaskEntity editedTask,
  ) async {
    try {
      await _db.editTaskToCache(
        TaskLocalModel.fromEntity(oldTask),
        TaskLocalModel.fromEntity(editedTask),
      );
      DementiappLogger.infoLog(
        'REPO:editTask to Local - edited $oldTask to $editedTask',
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
