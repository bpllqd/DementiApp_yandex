import 'dart:io' show Platform;
import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart';
import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:demetiapp/core/data/models/task_local_model.dart';
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
    }else{
      return 'user0';
    }
    return id;
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getAllTasks() async {
    try {

      final TaskApiModelWithRevision apiResult = await _api.getAllTasks();
      DementiappLogger.infoLog('REPO:getAllTasks - got tasks from api ${apiResult.listTasks}');
      final TaskLocalModelWithRevision localResult =
          await _db.getAllTasksFromCache();

      DementiappLogger.infoLog('REPO:getAllTasks - got tasks from local');

      final List<TaskApiModel> apiTasks = apiResult.listTasks;
      final List<TaskLocalModel> localTasks = localResult.listTasks;

      List<TaskEntity> entity =
          apiTasks.map((task) => TaskEntity.fromApiModel(task)).toList();
      List<TaskLocalModel> toLocal =
          entity.map((task) => TaskLocalModel.fromEntity(task)).toList();

      if (apiResult.apiRevision > localResult.localRevision) {
        final TaskLocalModelWithRevision localResult =
            await _db.updateAllTasksToCache(toLocal, apiResult.apiRevision);
            DementiappLogger.infoLog('REPO:getAllTasks - updated all tasks and revision in local');
        final List<TaskEntity> tasksList = localResult.listTasks
            .map((task) => TaskEntity.fromLocalModel(task))
            .toList();
        return Right(tasksList);
      }

      return Right(
        localTasks.map((task) => TaskEntity.fromLocalModel(task)).toList(),
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
    int revision,
  ) async {
    try {
      final List<TaskLocalModel> tasksToLocal =
          tasks.map((task) => TaskLocalModel.fromEntity(task)).toList();
      final List<TaskApiModel> tasksToApi =
          tasks.map((task) => TaskApiModel.fromEntity(task)).toList();

      final TaskApiModelWithRevision resultApi =
          await _api.updateAllTasks(tasksToApi, revision);
      await _db.updateAllTasksToCache(tasksToLocal, resultApi.apiRevision);

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(TaskEntity task) async {
    try {
      final TaskLocalModel taskToLocal = TaskLocalModel.fromEntity(task);
      final TaskApiModel taskToApi = TaskApiModel.fromEntity(task);

      await _db.deleteExactTaskFromCache(taskToLocal);
      await _api.deleteExactTask(taskToApi);

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getExactTask(TaskEntity task) async {
    try {
      final TaskLocalModel taskToLocal = TaskLocalModel.fromEntity(task);
      final TaskApiModel taskToApi = TaskApiModel.fromEntity(task);

      final TaskLocalModelWithRevision resultLocal =
          await _db.getExactTaskFromCache(taskToLocal);
      final TaskApiModelWithRevision resultApi = await _api.getExactTask(taskToApi);

      final List<TaskEntity> localTaskEntities = resultLocal.listTasks
          .map((localModel) => TaskEntity.fromLocalModel(localModel))
          .toList();      

      return Right(localTaskEntities[0]);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
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
      final TaskApiModel taskToApi = TaskApiModel.fromEntity(task);
      
      final TaskApiModelWithRevision apiAll = await _api.getAllTasks();
      final int apiRevision = apiAll.apiRevision;

      DementiappLogger.infoLog('REPO: createTask - got right revision: $apiRevision');

      final TaskLocalModelWithRevision resultLocal =
          await _db.createTaskToCache(taskToLocal, apiRevision);
      
      DementiappLogger.infoLog('REPO:createTask - created to Local: $resultLocal');

      final int localRevision = resultLocal.localRevision;
      await _api.createTask(taskToApi, localRevision);
      DementiappLogger.infoLog('REPO:createTask - created to api');

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
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
      final TaskApiModelWithRevision apiAll = await _api.getAllTasks();
      final int apiRevision = apiAll.apiRevision;

      await _db.editTaskToCache(
        TaskLocalModel.fromEntity(oldTask),
        TaskLocalModel.fromEntity(editedTask),
        apiRevision,
      );
      DementiappLogger.infoLog('REPO:editTask to Local - edited $oldTask to $editedTask');
      await _api.editTask(
        TaskApiModel.fromEntity(oldTask),
        TaskApiModel.fromEntity(editedTask),
        apiRevision,
      );
      DementiappLogger.infoLog('REPO:editTask to api - edited $oldTask to $editedTask');
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.toString()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
