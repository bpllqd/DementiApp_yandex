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
      await _db.createTaskToCache(TaskLocalModel.fromEntity(task));
      _api.createTask(TaskApiModel.fromEntity(task));
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
      await _db.deleteExactTaskFromCache(TaskLocalModel.fromEntity(task));
      _api.deleteExactTask(TaskApiModel.fromEntity(task));
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
      _api.editTask(TaskApiModel.fromEntity(oldTask), TaskApiModel.fromEntity(editedTask));
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
      List<TaskLocalModel> cacheResult = await _db.getAllTasksFromCache();
      List<TaskEntity> tasksFromCache = cacheResult.map((localTask) => TaskEntity.fromLocalModel(localTask)).toList();

      List<TaskApiModel> apiResult =await _api.getAllTasks();
      List<TaskEntity> tasksFromApi = apiResult.map((remoteTask) => TaskEntity.fromApiModel(remoteTask)).toList();
      //TODO: sync

      return Right(tasksFromCache);
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

    } on CacheException catch(e){
      return Left(CacheFailure(e.toString()));
    } on ServerException catch(e){
      return Left(ServerFailure(e.toString()));
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAllTasks() async {
    try{

    } on CacheException catch(e){
      return Left(CacheFailure(e.toString()));
    } on ServerException catch(e){
      return Left(ServerFailure(e.toString()));
    } catch(e){
      return Left(Failure(e.toString()));
    }
  }

}