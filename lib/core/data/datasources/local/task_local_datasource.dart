import 'package:demetiapp/core/data/datasources/local/database_helper.dart';
import 'package:demetiapp/core/data/datasources/local/database_mapper.dart';
import 'package:demetiapp/core/data/models/task_local_model.dart';
import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';


abstract class TaskLocalDataSource {
  /// Gets the last [List<TaskModel>] values from cache
  /// when the user had internet connection
  ///
  /// Throws [CacheException] if the errors occured.
  Future<List<TaskLocalModel>> getAllTasksFromCache();

  /// Updates the local [List<TaskModel>] if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> updateAllTasksToCache(List<TaskLocalModel> newTaskList);

  /// Gets the last [TaskApiModel] exact task from cache
  /// when the user had internet connection
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModel> getExactTaskFromCache(TaskLocalModel task);

  /// Deletes the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> deleteExactTaskFromCache(TaskLocalModel task);

  /// Creates the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> createTaskToCache(TaskLocalModel task);

  /// Edits the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> editTaskToCache(TaskLocalModel oldTask, TaskLocalModel editedTask);
}

class TaskLocalDatasourceImpl implements TaskLocalDataSource {

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  @override
  Future<void> createTaskToCache(TaskLocalModel task) async{
    final db = await _databaseHelper.database;

    final int result = await db.insert(
      'tasks',
      DBMapConverter.convertTaskForDB(task.toJson()),
    );
    
    if(result == 0){
      throw CacheException();
    }
  }

  @override
  Future<void> deleteExactTaskFromCache(TaskLocalModel task) async{
    final db = await _databaseHelper.database;

    final int result = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [task.id],
    );

    if (result == 0) {
      throw CacheException();
    }
  }

  @override
  Future<void> editTaskToCache(TaskLocalModel oldTask, TaskLocalModel editedTask) async{
    final db = await _databaseHelper.database;

    int result = await db.update(
      'tasks',
      DBMapConverter.convertTaskForDB(editedTask.toJson()),
      where: 'id = ?',
      whereArgs: [oldTask.id],
    );

    if(result == 0){
      throw CacheException();
    }
  }

  @override
  Future<List<TaskLocalModel>> getAllTasksFromCache() async{
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      Map<String, dynamic> taskMap = DBMapConverter.convertTaskFromDB(maps[i]);
        return TaskLocalModel.fromJson(taskMap);
    }
    );
  }

  @override
  Future<TaskLocalModel> getExactTaskFromCache(TaskLocalModel task) async{
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [task.id],
    );

    if (maps.isNotEmpty) {
      Map<String, dynamic> taskMap = DBMapConverter.convertTaskFromDB(maps.first);
      return TaskLocalModel.fromJson(taskMap);
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> updateAllTasksToCache(List<TaskLocalModel> newTaskList) async{
    final db = await _databaseHelper.database;
    
    await db.transaction(
      (txn) async{
        await txn.delete('tasks');

        DementiappLogger.infoLog('Tasks has been deleted from local DB with MEGAHOROSH');
        for(var task in newTaskList){
          await txn.insert('tasks', DBMapConverter.convertTaskForDB(task.toJson()));
        }
        DementiappLogger.infoLog('Tasks has been updated in local DB with MEGAHOROSH');
      }
    );
  }
}
