import 'package:demetiapp/core/data/models/task_api_model.dart';
import 'package:demetiapp/core/data/models/task_local_model.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';

class TaskMapper {
  static TaskEntity toEntityFromLocal(TaskLocalModel localModel) {
    return TaskEntity.fromLocalModel(localModel);
  }

  static TaskEntity toEntityFromApi(TaskApiModel apiModel) {
    return TaskEntity.fromApiModel(apiModel);
  }

  static TaskLocalModel toLocalModel(TaskEntity entity) {
    return TaskLocalModel.fromEntity(entity);
  }

  static TaskApiModel toApiModel(TaskEntity entity) {
    return TaskApiModel.fromEntity(entity);
  }

  static List<TaskApiModel> toApiModelList(List<TaskLocalModel> localModels) {
    return localModels
        .map((localModel) => toApiModel(toEntityFromLocal(localModel)))
        .toList();
  }

  static List<TaskLocalModel> toLocalModelList(List<TaskApiModel> apiModels) {
    return apiModels
        .map((apiModel) => toLocalModel(toEntityFromApi(apiModel)))
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
    return entities.map((entity) => toLocalModel(entity)).toList();
  }

  static List<TaskApiModel> toApiModelListFromListEntity(
    List<TaskEntity> entities,
  ) {
    return entities.map((entity) => toApiModel(entity)).toList();
  }
}
