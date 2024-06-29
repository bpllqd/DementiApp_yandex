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

class ToDoListRepositoryImpl implements ToDoListRepository{
  final TaskLocalDataSource _db;
  final TaskRemoteDataSource _api;
  static String? _id;

  ToDoListRepositoryImpl({required TaskLocalDataSource db, required TaskRemoteDataSource api}) : _db = db, _api = api;

    /// Получает user's id
    static Future<void> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      _id = iosDeviceInfo.identifierForVendor ?? '';
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      _id = androidDeviceInfo.id;
    }
    _id = 'Windows phone user lmao';
  }

  @override
  Future<Either<Failure, void>> createTask(TaskEntity task) async{
    task = task.copyWith(lastUpdatedBy: _id);
    try{
      final TaskLocalModel taskToLocal = TaskLocalModel.fromEntity(task);
      final TaskApiModel taskToApi = TaskApiModel.fromEntity(task);

      final TaskLocalModelWithRevision resultLocal = await _db.createTaskToCache(taskToLocal);
      final int localRevision = resultLocal.localRevision;
      await _api.createTask(taskToApi, localRevision);

      return const Right(null);
    } on CacheException catch (e){
      return Left(CacheFailure(e.toString()));
    } on ServerException catch (e){
      return Left(ServerFailure(e.toString()));
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(TaskEntity task) async{
    try{
      final TaskLocalModel taskToLocal = TaskLocalModel.fromEntity(task);
      final TaskApiModel taskToApi = TaskApiModel.fromEntity(task);

      await _db.deleteExactTaskFromCache(taskToLocal);
      await _api.deleteExactTask(taskToApi);
      
      return const Right(null);
    } on CacheException catch(e){
      return Left(CacheFailure(e.toString()));
    } on ServerException catch(e){
      return Left(ServerFailure(e.toString()));
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editTask(TaskEntity oldTask, TaskEntity editedTask) async{
    try{
      await _db.editTaskToCache(TaskLocalModel.fromEntity(oldTask), TaskLocalModel.fromEntity(editedTask));
      await _api.editTask(TaskApiModel.fromEntity(oldTask), TaskApiModel.fromEntity(editedTask));
      return const Right(null);
    } on CacheException catch(e){
      return Left(CacheFailure(e.toString()));
    } on ServerException catch(e){
      return Left(ServerFailure(e.toString()));
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getAllTasks() async {
    try{
      final TaskApiModelWithRevision apiResult = await _api.getAllTasks();
      final TaskLocalModelWithRevision localResult = await _db.getAllTasksFromCache();
      final List<TaskApiModel> apiTasks = apiResult.listTasks!;
      final List<TaskLocalModel> localTasks = localResult.listTasks!;

      List<TaskEntity> entity = apiTasks.map((task) => TaskEntity.fromApiModel(task)).toList();
      List<TaskLocalModel> toLocal = entity.map((task) => TaskLocalModel.fromEntity(task)).toList();

      if(apiResult.apiRevision > localResult.localRevision){
        final TaskLocalModelWithRevision localResult = await _db.updateAllTasksToCache(toLocal, apiResult.apiRevision);
        final List<TaskEntity> tasksList = localResult.listTasks!.map((task) => TaskEntity.fromLocalModel(task)).toList();
        return Right(tasksList);
      }

      return Right(localTasks.map((task) => TaskEntity.fromLocalModel(task)).toList());
    } on CacheException catch(e){
      return Left(CacheFailure(e.toString()));
    } on ServerException catch(e){
      return Left(ServerFailure(e.toString()));
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getExactTask(TaskEntity task) async{
    try{
      final TaskLocalModel taskToLocal = TaskLocalModel.fromEntity(task);
      final TaskApiModel taskToApi = TaskApiModel.fromEntity(task);

      final TaskLocalModelWithRevision resultLocal = await _db.getExactTaskFromCache(taskToLocal);
      await _api.getExactTask(taskToApi);

      return Right(TaskEntity.fromLocalModel(resultLocal.oneTask!));
    } on CacheException catch(e){
      return Left(CacheFailure(e.toString()));
    } on ServerException catch(e){
      return Left(ServerFailure(e.toString()));
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAllTasks(List<TaskEntity> tasks, int revision) async {
    try{
      final List<TaskLocalModel> tasksToLocal = tasks.map((task)=>TaskLocalModel.fromEntity(task)).toList();
      final List<TaskApiModel> tasksToApi = tasks.map((task)=>TaskApiModel.fromEntity(task)).toList();

      final TaskApiModelWithRevision resultApi = await _api.updateAllTasks(tasksToApi, revision);
      await _db.updateAllTasksToCache(tasksToLocal, resultApi.apiRevision);

      return const Right(null);
    } on CacheException catch(e){
      return Left(CacheFailure(e.toString()));
    } on ServerException catch(e){
      return Left(ServerFailure(e.toString()));
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

}