import 'dart:convert';
import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'dart:io' show Platform;

abstract class TaskRemoteDataSource {
  /// Calls the https://beta.mrdekk.ru/todo/list endpoint
  ///
  /// Throws the [ServerException] for all error codes.
  Future<TaskApiModelWithRevision> getAllTasks();

  /// Calls the https://beta.mrdekk.ru/todo/list endpoint
  ///
  /// Throws the [ServerException] for all error codes
  Future<TaskApiModelWithRevision> updateAllTasks(
    List<TaskApiModel> newTaskList,
    int revision,
  );

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
  Future<void> editTask(TaskApiModel oldTask, TaskApiModel editedTask, int revision);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

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

  TaskRemoteDataSourceImpl({required this.dio});

  @override
  Future<TaskApiModelWithRevision> createTask(
    TaskApiModel task,
    int revision,
  ) async {
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

    final taskToApi = jsonEncode({'element': task.toJson()});

    DementiappLogger.infoLog('API:createTask - task $taskToApi with revision $revision');

    if (response.statusCode == 200) {
      final int apiRevision = response.data!['revision'] as int;
      DementiappLogger.infoLog('API:createTask - api revision $apiRevision');
      final task = TaskApiModel.fromJson(response.data!['element'] as Map<String, dynamic>);

      final List<TaskApiModel> tasksFromApi = [];
      tasksFromApi.add(task);

      DementiappLogger.infoLog('API:createTask: created task:  $tasksFromApi');
      return TaskApiModelWithRevision(apiRevision: apiRevision, listTasks: tasksFromApi);
    } else {
      DementiappLogger.errorLog(
        'API:createTask code: ${response.statusCode}',
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
      final List<TaskApiModel> tasksFromApi = (dataFromApi['list'] as List)
          .map((task) => TaskApiModel.fromJson(task as Map<String, dynamic>))
          .toList();
      DementiappLogger.infoLog('API:deleteTask - deleted task: $tasksFromApi');
      return TaskApiModelWithRevision(apiRevision: apiRevision, listTasks: tasksFromApi);
    } else {
      DementiappLogger.errorLog(
        'API:deleteTask, code: ${response.statusCode}',
      );
      throw ServerException('Bad status while deleting in api');
    }
  }

  @override
  Future<void> editTask(TaskApiModel oldTask, TaskApiModel editedTask, int revision) async {
    final newTask = TaskApiModel.fromEntity(TaskEntity.fromApiModel(editedTask).copyWith(lastUpdatedBy: await getId()));
    Response<Map<String, dynamic>> response = await dio.put(
      '/list/${oldTask.id}',
      options: Options(
        headers: {
          'X-Last-Known-Revision': revision,
        },
        contentType: 'application/json',
      ),
      data: json.encode({'element': newTask.toJson()}),
    );
    DementiappLogger.infoLog('API:editTask - made response with status ${response.statusCode}');
    if (response.statusCode == 200) {
      DementiappLogger.infoLog('API:editTask - edited task');
    } else {
      DementiappLogger.errorLog(
        'API:editTask, code: ${response.statusCode}',
      );
      throw ServerException('Bad status while editing api');
    }
  }

  @override
  Future<TaskApiModelWithRevision> getAllTasks() async {
    Response<Map<String, dynamic>> response = await dio.get(
      '/list',
    );
    DementiappLogger.infoLog('API:getAllTasks - made response');
    if (response.statusCode == 200) {
      List<TaskApiModel> tasksFromApi = [];
      final int revisionFromApi = response.data!['revision'] as int;
      DementiappLogger.infoLog('API:getAllTasks - got revision $revisionFromApi');

      final List<TaskApiModel> tasks = (response.data!['list'] as List)
          .map((task) => TaskApiModel.fromJson(task as Map<String, dynamic>))
          .toList();
      DementiappLogger.infoLog('API:getAllTasks - made List<TaskApiModel>');
      tasksFromApi.addAll(tasks);
      DementiappLogger.infoLog('API:getAllTasks got tasks with reviion $revisionFromApi');
      return TaskApiModelWithRevision(
          apiRevision: revisionFromApi,
          listTasks: tasksFromApi,
      );
    } else {
      DementiappLogger.errorLog(
        'API:getAllTasks, code: ${response.statusCode}',
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
      final List<TaskApiModel> tasksFromApi= [];
      tasksFromApi.add(TaskApiModel.fromJson(
        response.data!['element'] as Map<String, dynamic>,
      ),);
      final int apiRevision = response.data!['revision'] as int;
      DementiappLogger.infoLog('API:getExactTask - got task $tasksFromApi anf revision $apiRevision');
      return TaskApiModelWithRevision(
        apiRevision: apiRevision,
        listTasks: tasksFromApi,
      );
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException('Bad status  in getExactTask from api');
    }
  }

  @override
  Future<TaskApiModelWithRevision> updateAllTasks(
    List<TaskApiModel> newTaskList,
    int revision,
  ) async {
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
      DementiappLogger.infoLog('API:updateAllTasks - updated tasks $tasksFromApi and revision $revisionFromApi');
      return TaskApiModelWithRevision(
        apiRevision: revisionFromApi,
        listTasks: tasksFromApi,
      );
    } else {
      DementiappLogger.errorLog(
        'Bad status from Api, code: ${response.statusCode}',
      );
      throw ServerException('Bad status from api (updateAll)');
    }
  }
}
