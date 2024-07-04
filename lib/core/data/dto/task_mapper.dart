import 'package:demetiapp/core/data/dto/task_api_model.dart';
import 'package:demetiapp/core/data/dto/task_local_model.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';

class TaskMapper {
  static TaskEntity fromLocalModel(TaskLocalModel model) {
    return TaskEntity(
      id: model.id,
      text: model.text,
      importance: model.importance,
      deadline: model.deadline,
      done: model.done,
      color: model.color,
      createdAt: model.createdAt,
      changedAt: model.changedAt,
      lastUpdatedBy: model.lastUpdatedBy,
    );
  }

  static TaskEntity fromApiModel(TaskApiModel model) {
    return TaskEntity(
      id: model.id,
      text: model.text,
      importance: model.importance,
      deadline: model.deadline,
      done: model.done,
      color: model.color,
      createdAt: model.createdAt,
      changedAt: model.changedAt,
      lastUpdatedBy: model.lastUpdatedBy,
    );
  }

  static TaskEntity toEntityFromLocal(TaskLocalModel localModel) {
    return fromLocalModel(localModel);
  }

  static TaskEntity toEntityFromApi(TaskApiModel apiModel) {
    return fromApiModel(apiModel);
  }

  static TaskLocalModel toLocalFromEntity(TaskEntity entity) {
    return TaskLocalModel.fromEntity(entity);
  }

  static TaskApiModel toApiFromEntity(TaskEntity entity) {
    return TaskApiModel.fromEntity(entity);
  }

  static List<TaskApiModel> toApiModelList(List<TaskLocalModel> localModels) {
    return localModels
        .map((localModel) => toApiFromEntity(toEntityFromLocal(localModel)))
        .toList();
  }

  static List<TaskLocalModel> toLocalModelList(List<TaskApiModel> apiModels) {
    return apiModels
        .map((apiModel) => toLocalFromEntity(toEntityFromApi(apiModel)))
        .toList();
  }

  static List<TaskEntity> toEntityListFromLocal(
    List<TaskLocalModel> localModels,
  ) {
    return localModels
        .map((localModel) => toEntityFromLocal(localModel))
        .toList();
  }

  static List<TaskEntity> toEntityListFromApi(List<TaskApiModel> apiModels) {
    return apiModels.map((apiModel) => toEntityFromApi(apiModel)).toList();
  }

  static List<TaskLocalModel> toLocalModelListFromListEntity(
    List<TaskEntity> entities,
  ) {
    return entities.map((entity) => toLocalFromEntity(entity)).toList();
  }

  static List<TaskApiModel> toApiModelListFromListEntity(
    List<TaskEntity> entities,
  ) {
    return entities.map((entity) => toApiFromEntity(entity)).toList();
  }
}
