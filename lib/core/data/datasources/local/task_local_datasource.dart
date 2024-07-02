import 'package:demetiapp/core/data/datasources/local/database_helper.dart';
import 'package:demetiapp/core/data/datasources/local/database_mapper.dart';
import 'package:demetiapp/core/data/models/task_local_model.dart';
import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' show Platform;

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
    int newRevision,
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
  Future<TaskLocalModelWithRevision> deleteExactTaskFromCache(
    TaskLocalModel task,
  );

  /// Creates the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModelWithRevision> createTaskToCache(TaskLocalModel task, int revision);

  /// Edits the local [TaskApiModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskLocalModelWithRevision> editTaskToCache(
    TaskLocalModel oldTask,
    TaskLocalModel editedTask,
    int revision,
  );
}

class TaskLocalDatasourceImpl implements TaskLocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  static String id = '';

  static Future<String> getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      id = iosDeviceInfo.identifierForVendor ?? '';
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      id = androidDeviceInfo.id;
    } else {
      id = 'Windows phone user lmao';
    }
    return id;
  }

  @override
  Future<int> getRevision(Database db) async {
    final List<Map<String, dynamic>> result =
        await db.query('metadata', where: 'id = ?', whereArgs: [1]);
    return result[0]['revision'] as int;
  }

  Future<List<String>> getTableColumns(Database db, String tableName) async {
    List<Map<String, dynamic>> columns =
        await db.rawQuery('PRAGMA table_info($tableName)');
    List<String> columnNames =
        columns.map((column) => column['name'] as String).toList();
    return columnNames;
  }

  @override
  Future<TaskLocalModelWithRevision> createTaskToCache(
    TaskLocalModel task,
    int revision,
  ) async {
    final db = await _databaseHelper.database;

    TaskEntity entity = TaskEntity.fromLocalModel(task);
    entity = entity.copyWith(lastUpdatedBy: await getId());
    task = TaskLocalModel.fromEntity(entity);


    await db.update(
      'metadata',
      {'revision': revision},
      where: 'id = ?',
      whereArgs: [1],
    );
      
      DementiappLogger.infoLog('LOCAL:createTask - update revision: ${_databaseHelper.getRev()}');
  
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

    final int updatedRevision = await getRevision(db);
    return TaskLocalModelWithRevision(localRevision: updatedRevision, listTasks: []);
  }

  @override
  Future<TaskLocalModelWithRevision> deleteExactTaskFromCache(
    TaskLocalModel task,
  ) async {
    final db = await _databaseHelper.database;


    int result = await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [task.id],
    );
    DementiappLogger.infoLog('LOCAL:deleteExactTask - task $task has been deleted');
    if (result == 0) {
      DementiappLogger.errorLog(
        'Deleting task from cache has been ended with DEADINSIDE',
      );
      throw CacheException(
        'Error while deleting task from cache. Please, try again later',
      );
    }

    final int updatedRevision = await getRevision(db);
    return TaskLocalModelWithRevision(localRevision: updatedRevision, listTasks: []);
  }

  @override
  Future<TaskLocalModelWithRevision> editTaskToCache(
    TaskLocalModel oldTask,
    TaskLocalModel editedTask,
    int revision,
  ) async {
    final db = await _databaseHelper.database;
    DementiappLogger.infoLog('LOCAL:editTask - editing in local');
    final newTask = TaskLocalModel.fromEntity(TaskEntity.fromLocalModel(editedTask).copyWith(lastUpdatedBy: await getId()));
    await db.update(
      'metadata',
      {'revision': revision},
      where: 'id = ?',
      whereArgs: [1],
    );
    DementiappLogger.infoLog('LOCAL:editTask - updated revision to $revision');
    final int result = await db.update(
        'tasks',
        DBMapConverter.convertTaskForDB(newTask.toJson()),
        where: 'id = ?',
        whereArgs: [oldTask.id],
      );
    DementiappLogger.infoLog('LOCAL:editTask - edited $oldTask to $newTask');
    if (result == 0) {
      throw CacheException(
        'Error while editing task in cache. Please, try again later',
      );
    }

    final int updatedRevision = await getRevision(db);
    return TaskLocalModelWithRevision(localRevision: updatedRevision, listTasks: []);
  }

  @override
  Future<TaskLocalModelWithRevision> getAllTasksFromCache() async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query('tasks');
    for(var task in maps){
      print(TaskLocalModel.fromJson(DBMapConverter.convertTaskFromDB(task)));
    }
    final int localRevision = await getRevision(db);
    DementiappLogger.infoLog('LOCAL:getAllTasks - got all tasks and revision $localRevision');

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
    Map<String, dynamic> taskMap =
        DBMapConverter.convertTaskFromDB(maps.first);
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
    int newRevision,
  ) async {
    final db = await _databaseHelper.database;

    await db.update(
      'metadata',
      {'revision': newRevision},
      where: 'id = ?',
      whereArgs: [1],
    );
    DementiappLogger.infoLog('LOCAL:updateAllTasks - updated local revision to $newRevision');
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
    DementiappLogger.infoLog('LOCAL:updateAllTasks - tasks and revision $revision updated');

    return TaskLocalModelWithRevision(
      localRevision: revision,
      listTasks: tasks,
    );
  }
}
