import 'package:demetiapp/core/data/datasources/local/database_helper.dart';
import 'package:demetiapp/core/data/datasources/local/database_mapper.dart';
import 'package:demetiapp/core/data/models/task_local_model.dart';
import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:sqflite/sqflite.dart';


abstract class TaskLocalDataSource {
  Future<int> getRevision(Database db);
  /// Gets the last [List<TaskModel>] values from cache
  /// when the user had internet connection
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModelWithRevision> getAllTasksFromCache();

  /// Updates the local [List<TaskModel>] if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModelWithRevision> updateAllTasksToCache(List<TaskLocalModel> newTaskList, int newRevision);

  /// Gets the last [TaskApiModel] exact task from cache
  /// when the user had internet connection
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModelWithRevision> getExactTaskFromCache(TaskLocalModel task);

  /// Deletes the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModelWithRevision> deleteExactTaskFromCache(TaskLocalModel task);

  /// Creates the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModelWithRevision> createTaskToCache(TaskLocalModel task);

  /// Edits the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModelWithRevision> editTaskToCache(TaskLocalModel oldTask, TaskLocalModel editedTask);
}

class TaskLocalDatasourceImpl implements TaskLocalDataSource {

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  @override
  Future<int> getRevision(Database db) async {
    final List<Map<String, dynamic>> result = await db.query('metadata', where: 'id = ?', whereArgs: [1]);
    return result[0]['revision'] as int;
  }

  Future<void> updateRevision(Database db, int newRevision) async {
    await db.update('metadata', {'revision': newRevision}, where: 'id = ?', whereArgs: [1]);
  }

  @override
  Future<TaskLocalModelWithRevision> createTaskToCache(TaskLocalModel task) async{
    final db = await _databaseHelper.database;

    final int result = await db.transaction(
      (txn) async{
        int result = await db.insert(
          'tasks',
          DBMapConverter.convertTaskForDB(task.toJson()),
        );

        return result;
      }
    );
    
    if(result == 0){
      DementiappLogger.errorLog('Writing task to cache has been ended with DEADINSIDE');
      throw CacheException('Error while writing to cache. Please, try again later');
    }

    final int updatedRevision = await getRevision(db);
    return TaskLocalModelWithRevision(localRevision: updatedRevision);
  }

  @override
  Future<TaskLocalModelWithRevision> deleteExactTaskFromCache(TaskLocalModel task) async{
    final db = await _databaseHelper.database;

    final int result = await db.transaction(
      (txn) async{
        int result = await db.delete(
          'tasks',
          where: 'id = ?',
          whereArgs: [task.id],
        );
        return result;
      }
    );

    if (result == 0) {
      DementiappLogger.errorLog('Deleting task from cache has been ended with DEADINSIDE');
      throw CacheException('Error while deleting task from cache. Please, try again later');
    }

    final int updatedRevision = await getRevision(db);
    return TaskLocalModelWithRevision(localRevision: updatedRevision);
  }

  @override
  Future<TaskLocalModelWithRevision> editTaskToCache(TaskLocalModel oldTask, TaskLocalModel editedTask) async{
    final db = await _databaseHelper.database;

    final int result = await db.transaction(
      (txn) async{
        int result = await db.update(
          'tasks',
          DBMapConverter.convertTaskForDB(editedTask.toJson()),
          where: 'id = ?',
          whereArgs: [oldTask.id],
        );

        return result;
      }
    );

    if(result == 0){
      DementiappLogger.errorLog('Editing task in cache has been ended with DEADINSIDE');
      throw CacheException('Error while editing task in cache. Please, try again later');
    }

    final int updatedRevision = await getRevision(db);
    return TaskLocalModelWithRevision(localRevision: updatedRevision);
  }

  @override
  Future<TaskLocalModelWithRevision> getAllTasksFromCache() async{
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query('tasks');
    final int localRevision = await getRevision(db);
    final List<TaskLocalModel> tasks = List.generate(maps.length, (i) {
      Map<String, dynamic> taskMap = DBMapConverter.convertTaskFromDB(maps[i]);
        return TaskLocalModel.fromJson(taskMap);
      }
    );
    return TaskLocalModelWithRevision(listTasks: tasks, localRevision: localRevision);
  }

  @override
  Future<TaskLocalModelWithRevision> getExactTaskFromCache(TaskLocalModel task) async{
    final db = await _databaseHelper.database;
    final int localRevision = await getRevision(db);

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [task.id],
    );

    if (maps.isNotEmpty) {
      Map<String, dynamic> taskMap = DBMapConverter.convertTaskFromDB(maps.first);
      return TaskLocalModelWithRevision(oneTask: TaskLocalModel.fromJson(taskMap), localRevision: localRevision);
    } else {
      DementiappLogger.errorLog('Getting task from cache has been ended with DEADINSIDE');
      throw CacheException('Error while getting task from cache. Please, try again later');
    }
  }

  @override
  Future<TaskLocalModelWithRevision> updateAllTasksToCache(List<TaskLocalModel> newTaskList, int newRevision) async{
    final db = await _databaseHelper.database;

    await db.transaction(
      (txn) async{
        await txn.delete('tasks');
        for(var task in newTaskList){
          await txn.insert('tasks', DBMapConverter.convertTaskForDB(task.toJson()));
        }
        await updateRevision(db, newRevision);
      }
    );
    final TaskLocalModelWithRevision result = await getAllTasksFromCache();
    final int revision = result.localRevision;
    final List<TaskLocalModel> tasks = result.listTasks!;

    return TaskLocalModelWithRevision(localRevision: revision, listTasks: tasks);
  }
}
