import 'dart:convert';

import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:dio/dio.dart';

abstract class TaskRemoteDataSource {
  /// Calls the https://beta.mrdekk.ru/todo/list endpoint
  ///
  /// Throws the [ServerException] for all error codes.
  Future<List<TaskApiModel>> getAllTasks();

  /// Calls the https://beta.mrdekk.ru/todo/list endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> updateAllTasks(List<TaskApiModel> newTaskList);

  /// Calls the https://beta.mrdekk.ru/todo/list/<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<TaskApiModel> getExactTask(TaskApiModel task);

  /// Calls the https://beta.mrdekk.ru/todo/list/<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> deleteExactTask(TaskApiModel task);

  /// Calls the https://beta.mrdekk.ru/todo/list/<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> createTask(TaskApiModel task);

  /// Calls the https://beta.mrdekk.ru/todo/list<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> editTask(TaskApiModel oldTask, TaskApiModel editedTask);
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

  Future<void> syncData(List<TaskApiModel> tasks, int? revision) async {
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
  Future<void> createTask(TaskApiModel task) async {
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
  Future<void> deleteExactTask(TaskApiModel task) async {
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
  Future<void> editTask(TaskApiModel oldTask, TaskApiModel editedTask) async {
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
  Future<List<TaskApiModel>> getAllTasks() async {
    Response<Map<String, dynamic>> response = await dio.get(
      '$baseUrl/list',
    );

    if (response.statusCode == 200) {
      final tasksFromApi = json.decode(response.data.toString());
      DementiappLogger.infoLog('Tasks loaded with MEGAHOROSH');
      return (tasksFromApi['list'] as List)
          .map((task) => TaskApiModel.fromJson(task as Map<String, dynamic>))
          .toList();
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException();
    }
  }

  @override
  Future<TaskApiModel> getExactTask(TaskApiModel task) async {
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
      return TaskApiModel.fromJson(taskFromApi as Map<String, dynamic>);
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException();
    }
  }

  @override
  Future<void> updateAllTasks(List<TaskApiModel> newTaskList) async {
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
