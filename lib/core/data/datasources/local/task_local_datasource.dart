import 'package:demetiapp/core/data/datasources/local/database_helper.dart';
import 'package:demetiapp/core/data/datasources/local/database_mapper.dart';
import 'package:demetiapp/core/data/dto/task_local_dto.dart';
import 'package:demetiapp/core/data/dto/task_api_dto.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:injectable/injectable.dart';
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
  Future<TaskLocalModelWithRevision> updateAllTasksToCache(
    List<TaskLocalModel> newTaskList,
  );

  /// Gets the last [TaskApiModel] exact task from cache
  /// when the user had internet connection
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModelWithRevision> getExactTaskFromCache(TaskLocalModel task);

  /// Deletes the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> deleteExactTaskFromCache(
    TaskLocalModel task,
  );

  /// Creates the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> createTaskToCache(
    TaskLocalModel task,
  );

  /// Edits the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> editTaskToCache(
    TaskLocalModel oldTask,
    TaskLocalModel editedTask,
  );

  void updateLocalRevision(int revision);
}
@injectable
class TaskLocalDatasourceImpl implements TaskLocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void updateLocalRevision(int revision) async {
    final db = await _databaseHelper.database;
    await db.update(
      'metadata',
      {'revision': revision},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  @override
  Future<int> getRevision(Database db) async {
    final List<Map<String, dynamic>> result =
        await db.query('metadata', where: 'id = ?', whereArgs: [1]);
    return result[0]['revision'] as int;
  }

  @override
  Future<void> createTaskToCache(
    TaskLocalModel task,
  ) async {
    final db = await _databaseHelper.database;

    final int loading = await db.insert(
      'tasks',
      DBMapConverter.convertTaskForDB(task.toJson()),
    );

    if (loading == 0) {
      DementiappLogger.errorLog(
        'Writing task to cache has been ended with DEADINSIDE',
      );
      throw CacheException(
        'Error while writing to cache. Please, try again later',
      );
    }
  }

  @override
  Future<void> deleteExactTaskFromCache(
    TaskLocalModel task,
  ) async {
    final db = await _databaseHelper.database;

    int result = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [task.id],
    );
    DementiappLogger.infoLog(
      'LOCAL:deleteExactTask - task $task has been deleted',
    );
    if (result == 0) {
      DementiappLogger.errorLog(
        'Deleting task from cache has been ended with DEADINSIDE',
      );
      throw CacheException(
        'Error while deleting task from cache. Please, try again later',
      );
    }
  }

  @override
  Future<void> editTaskToCache(
    TaskLocalModel oldTask,
    TaskLocalModel editedTask,
  ) async {
    final db = await _databaseHelper.database;
    DementiappLogger.infoLog('LOCAL:editTask - editing in local');

    final int result = await db.update(
      'tasks',
      DBMapConverter.convertTaskForDB(editedTask.toJson()),
      where: 'id = ?',
      whereArgs: [oldTask.id],
    );
    DementiappLogger.infoLog('LOCAL:editTask - edited $oldTask to $editedTask');
    if (result == 0) {
      throw CacheException(
        'Error while editing task in cache. Please, try again later',
      );
    }
  }

  @override
  Future<TaskLocalModelWithRevision> getAllTasksFromCache() async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query('tasks');
    final int localRevision = await getRevision(db);
    DementiappLogger.infoLog(
      'LOCAL:getAllTasks - got all tasks and revision $localRevision',
    );

    final List<TaskLocalModel> tasks = List.generate(maps.length, (i) {
      Map<String, dynamic> taskMap = DBMapConverter.convertTaskFromDB(maps[i]);
      return TaskLocalModel.fromJson(taskMap);
    });
    DementiappLogger.infoLog('LOCAL:getAll - converted tasks to List');
    return TaskLocalModelWithRevision(
      listTasks: tasks,
      localRevision: localRevision,
    );
  }

  @override
  Future<TaskLocalModelWithRevision> getExactTaskFromCache(
    TaskLocalModel task,
  ) async {
    final db = await _databaseHelper.database;
    final int localRevision = await getRevision(db);
    List<TaskLocalModel> tasks = [];

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [task.id],
    );
    Map<String, dynamic> taskMap = DBMapConverter.convertTaskFromDB(maps.first);
    tasks.add(TaskLocalModel.fromJson(taskMap));
    DementiappLogger.infoLog('LOCAL:getExactTsk - got task $tasks');
    return TaskLocalModelWithRevision(
      listTasks: tasks,
      localRevision: localRevision,
    );
  }

  @override
  Future<TaskLocalModelWithRevision> updateAllTasksToCache(
    List<TaskLocalModel> newTaskList,
  ) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      await txn.delete('tasks');
      if (newTaskList.isNotEmpty) {
        for (var task in newTaskList) {
          await txn.insert(
            'tasks',
            DBMapConverter.convertTaskForDB(task.toJson()),
          );
        }
      }
    });

    DementiappLogger.infoLog('LOCAL:updateAllTasks - updated all tasks');

    final TaskLocalModelWithRevision result = await getAllTasksFromCache();
    final int revision = result.localRevision;
    final List<TaskLocalModel> tasks = result.listTasks;
    DementiappLogger.infoLog(
      'LOCAL:updateAllTasks - tasks and revision $revision updated',
    );

    return TaskLocalModelWithRevision(
      localRevision: revision,
      listTasks: tasks,
    );
  }
}
