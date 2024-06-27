import 'dart:convert';

import 'package:demetiapp/core/data/models/task_model.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:dio/dio.dart';

abstract class TaskRemoteDataSource {
  /// Calls the https://beta.mrdekk.ru/todo/list endpoint
  ///
  /// Throws the [ServerException] for all error codes.
  Future<List<TaskModel>> getAllTasks();

  /// Calls the https://beta.mrdekk.ru/todo/list endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> updateAllTasks(List<TaskModel> newTaskList);

  /// Calls the https://beta.mrdekk.ru/todo/list/<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<TaskModel> getExactTask(TaskModel task);

  /// Calls the https://beta.mrdekk.ru/todo/list/<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> deleteExactTask(TaskModel task);

  /// Calls the https://beta.mrdekk.ru/todo/list/<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> createTask(TaskModel task, int revision);

  /// Calls the https://beta.mrdekk.ru/todo/list<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> editTask(TaskModel oldTask, TaskModel editedTask);
}

/// TODO: Dont forget to pass base options in dio
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  int? revision;
  final String baseUrl = 'https://beta.mrdekk.ru/todo';
  final Dio dio;

  TaskRemoteDataSourceImpl({required this.dio});

  Future<void> getRevision() async {
    if (revision == null) {
      await getAllTasks();
    }
    return;
  }

  Future<void> syncData(List<TaskModel> tasks, int? revision) async {
    getRevision();
    List<Map<String, dynamic>> tasksFromApi = [];
    for (var element in tasks) {
      tasksFromApi.add(element.toJson());
    }
    try {
      Response<Map<String, dynamic>> response = await dio.patch(
        '/list',
        options: Options(
          headers: {
            "X-Last-Known-Revision": revision,
          },
          contentType: 'application/json',
        ),
        data: jsonEncode({'element': tasksFromApi}),
      );
      revision = response.data!['revision'] as int;
      DementiappLogger.infoLog('Sync ended with MEGAHOROSH');
    } catch (e) {
      DementiappLogger.errorLog('Bad status from Api, ${e.toString()}');
    }
  }

  @override
  Future<void> createTask(TaskModel task, int revision) async {
    Response<Map<String, dynamic>> response = await dio.post(
      '$baseUrl/list',
      options: Options(
        headers: {
          'X-Last-Known-Revision': revision,
        },
        contentType: 'application/json',
      ),
      data: jsonEncode({'element': task.toJson()}),
    );

    if (response.statusCode == 200) {
      DementiappLogger.infoLog(
        'Creating task ${task.id} ended with MEGAHOROSH',
      );
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException();
    }
  }

  @override
  Future<void> deleteExactTask(TaskModel task) async {
    await getRevision();
    Response<Map<String, dynamic>> response = await dio.delete(
      '$baseUrl/list/${task.id}',
      options: Options(
        headers: {
          'X-Last-Known-Revision': revision,
        },
        contentType: 'application/json',
      ),
    );

    if (response.statusCode == 200) {
      DementiappLogger.infoLog(
        'Task ${task.id} deletion ended with MEGAHOROSH',
      );
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException();
    }
  }

  @override
  Future<void> editTask(TaskModel oldTask, TaskModel editedTask) async {
    await getRevision();
    Response<Map<String, dynamic>> response = await dio.patch(
      '$baseUrl/list/${oldTask.id}',
      options: Options(
        headers: {
          'X-Last-Known-Revision': revision,
        },
        contentType: 'application/json',
      ),
      data: json.encode({'element': editedTask.toJson()}),
    );

    if (response.statusCode == 200) {
      DementiappLogger.infoLog('Task ${editedTask.id} updated with MEGAHOROSH');
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException();
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks() async {
    Response<Map<String, dynamic>> response = await dio.get(
      '$baseUrl/list',
    );

    if (response.statusCode == 200) {
      final tasksFromApi = json.decode(response.data.toString());
      DementiappLogger.infoLog('Tasks loaded with MEGAHOROSH');
      return (tasksFromApi['list'] as List)
          .map((task) => TaskModel.fromJson(task as Map<String, dynamic>))
          .toList();
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException();
    }
  }

  @override
  Future<TaskModel> getExactTask(TaskModel task) async {
    await getRevision();
    Response<Map<String, dynamic>> response = await dio.get(
      '$baseUrl/list/${task.id}',
      options: Options(
        headers: {
          'X-Last-Known-Revision': revision,
        },
        contentType: 'application/json',
      ),
    );

    if (response.statusCode == 200) {
      DementiappLogger.infoLog('Task ${task.id} loaded with MEGAHOROSH');
      final taskFromApi = json.decode(response.data.toString());
      return TaskModel.fromJson(taskFromApi as Map<String, dynamic>);
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException();
    }
  }

  @override
  Future<void> updateAllTasks(List<TaskModel> newTaskList) async {
    getRevision();

    List<Map<String, dynamic>> jsonTasks =
        newTaskList.map((task) => task.toJson()).toList();
    Map<String, dynamic> requestBody = {'list': jsonTasks};

    Response<Map<String, dynamic>> response = await dio.patch(
      '$baseUrl/list',
      options: Options(
        headers: {
          'X-Last-Known-Revision': revision,
        },
        contentType: 'application/json',
      ),
      data: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      DementiappLogger.infoLog(
        'Updating all the tasks has ended with MEGAHOROSH',
      );
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException();
    }
  }
}
