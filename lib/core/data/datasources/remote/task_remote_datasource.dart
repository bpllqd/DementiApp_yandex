import 'dart:convert';
import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class TaskRemoteDataSource {
  /// Calls the https://beta.mrdekk.ru/todo/list endpoint
  ///
  /// Throws the [ServerException] for all error codes.
  Future<TaskApiModelWithRevision> getAllTasks();

  /// Calls the https://beta.mrdekk.ru/todo/list endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<TaskApiModelWithRevision> updateAllTasks(
      List<TaskApiModel> newTaskList, int revision,);

  /// Calls the https://beta.mrdekk.ru/todo/list/<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<TaskApiModelWithRevision> getExactTask(TaskApiModel task);

  /// Calls the https://beta.mrdekk.ru/todo/list/<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<TaskApiModelWithRevision> deleteExactTask(TaskApiModel task);

  /// Calls the https://beta.mrdekk.ru/todo/list/<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> createTask(TaskApiModel task, int revision);

  /// Calls the https://beta.mrdekk.ru/todo/list<id> endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<void> editTask(TaskApiModel oldTask, TaskApiModel editedTask);
}

/// TODO: Dont forget to pass base options in dio
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl({required this.dio});

  @override
  Future<TaskApiModelWithRevision> createTask(
      TaskApiModel task, int revision,) async {
    Response<Map<String, dynamic>> response = await dio.post(
      '/list',
      options: Options(
        headers: {
          'X-Last-Known-Revision': revision,
        },
        contentType: 'application/json',
      ),
      data: jsonEncode({'element': task.toJson()}),
    );

    if (response.statusCode == 200) {
      final int apiRevision = response.data!['revision'] as int;
      return TaskApiModelWithRevision(apiRevision: apiRevision);
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException('Bad status in createTask api');
    }
  }

  @override
  Future<TaskApiModelWithRevision> deleteExactTask(TaskApiModel task) async {
    Response<Map<String, dynamic>> response = await dio.delete(
      '/list/${task.id}',
    );

    if (response.statusCode == 200) {
      final dataFromApi = json.decode(response.data.toString());
      final int apiRevision = dataFromApi['revision'] as int;
      return TaskApiModelWithRevision(apiRevision: apiRevision);
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException('Bad status while deleting in api');
    }
  }

  @override
  Future<void> editTask(TaskApiModel oldTask, TaskApiModel editedTask) async {
    Response<Map<String, dynamic>> response = await dio.patch(
      '/list/${oldTask.id}',
      data: json.encode({'element': editedTask.toJson()}),
    );

    if (response.statusCode == 200) {
      DementiappLogger.infoLog('Task ${editedTask.id} updated with MEGAHOROSH');
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException('Bad status while editing api');
    }
  }

  @override
  Future<TaskApiModelWithRevision> getAllTasks() async {
    Response<Map<String, dynamic>> response = await dio.get(
      '/list',
    );
    if (response.statusCode == 200) {
      final List<TaskApiModel> tasksFromApi = (response.data!['list'] as List)
          .map((task) => TaskApiModel.fromJson(task as Map<String, dynamic>))
          .toList();
      debugPrint('$tasksFromApi');
      final int revisionFromApi = response.data!['revision'] as int;
      debugPrint('$revisionFromApi');

      return TaskApiModelWithRevision(
          apiRevision: revisionFromApi, listTasks: tasksFromApi,);
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException('Bad status from api (get all)');
    }
  }

  @override
  Future<TaskApiModelWithRevision> getExactTask(TaskApiModel task) async {
    Response<Map<String, dynamic>> response = await dio.get(
      '/list/${task.id}',
    );

    if (response.statusCode == 200) {
      DementiappLogger.infoLog('Task ${task.id} loaded with MEGAHOROSH');
      final TaskApiModel taskFromApi = TaskApiModel.fromJson(
          response.data!['element'] as Map<String, dynamic>,);
      final int apiRevision = response.data!['revision'] as int;
      return TaskApiModelWithRevision(
          apiRevision: apiRevision, oneTask: taskFromApi,);
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException('Bad status  in getExactTask from api');
    }
  }

  @override
  Future<TaskApiModelWithRevision> updateAllTasks(
      List<TaskApiModel> newTaskList, int revision,) async {
    List<Map<String, dynamic>> jsonTasks =
        newTaskList.map((task) => task.toJson()).toList();
    Map<String, dynamic> requestBody = {'list': jsonTasks};

    Response<Map<String, dynamic>> response = await dio.patch(
      '/list',
      options: Options(
        headers: {
          'X-Last-Known-Revision': revision,
        },
        contentType: 'application/json',
      ),
      data: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final dataFromApi = json.decode(response.data.toString());
      final List<TaskApiModel> tasksFromApi = (dataFromApi['list'] as List)
          .map((task) => TaskApiModel.fromJson(task as Map<String, dynamic>))
          .toList();
      final int revisionFromApi = dataFromApi['revision'] as int;

      return TaskApiModelWithRevision(
          apiRevision: revisionFromApi, listTasks: tasksFromApi,);
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException('Bad status from api (updateAll)');
    }
  }
}
