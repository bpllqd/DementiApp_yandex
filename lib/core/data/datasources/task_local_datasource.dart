import 'package:demetiapp/core/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  /// Gets the last [List<TaskModel>] values from cache
  /// when the user had internet connection
  ///
  /// Throws [CacheException] if the errors occured.
  Future<List<TaskModel>> getAllTasksFromCache();

  /// Updates the local [List<TaskModel>] if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> updateAllTasksToCache(List<TaskModel> newTaskList);

  /// Gets the last [TaskModel] exact task from cache
  /// when the user had internet connection
  ///
  /// Throws [CacheException] if the errors occured.
  Future<TaskModel> getExactTaskFromCache(TaskModel task);

  /// Deletes the local [TaskModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> deleteExactTaskFromCache(TaskModel task);

  /// Creates the local [TaskModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> createTaskToCache(TaskModel task, int revision);

  /// Edits the local [TaskModel] task if there is
  /// no internet connection.
  ///
  /// Throws [CacheException] if the errors occured.
  Future<void> editTaskToCache(TaskModel oldTask, TaskModel editedTask);
}

class TaskLocalDatasourceImpl implements TaskLocalDataSource {
  @override
  Future<void> createTaskToCache(TaskModel task, int revision) {
    // TODO: implement createTaskToCache
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExactTaskFromCache(TaskModel task) {
    // TODO: implement deleteExactTaskFromCache
    throw UnimplementedError();
  }

  @override
  Future<void> editTaskToCache(TaskModel oldTask, TaskModel editedTask) {
    // TODO: implement editTaskToCache
    throw UnimplementedError();
  }

  @override
  Future<List<TaskModel>> getAllTasksFromCache() {
    // TODO: implement getAllTasksFromCache
    throw UnimplementedError();
  }

  @override
  Future<TaskModel> getExactTaskFromCache(TaskModel task) {
    // TODO: implement getExactTaskFromCache
    throw UnimplementedError();
  }

  @override
  Future<void> updateAllTasksToCache(List<TaskModel> newTaskList) {
    // TODO: implement updateAllTasksToCache
    throw UnimplementedError();
  }
}
