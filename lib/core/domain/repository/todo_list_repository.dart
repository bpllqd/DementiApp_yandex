import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/error/failure.dart';

abstract class ToDoListRepository {
  Future<Either<Failure, List<TaskEntity>>> getAllTasks(); //GET $BASEURL/list

  Future<Either<Failure, void>> updateAllTasks(
      List<TaskEntity> tasks, int revision,); //PATCH $BASEURL/list

  Future<Either<Failure, void>> deleteTask(
    TaskEntity task,
  ); // DELETE $BASEURL/list/<id>

  Future<Either<Failure, TaskEntity>> getExactTask(
    TaskEntity task,
  ); //GET $BASEURL/list/<id>

  Future<Either<Failure, void>> createTask(
    TaskEntity task,
  ); //DELETE $BASEURL/list/<id>

  Future<Either<Failure, void>> editTask(
    TaskEntity oldTask,
    TaskEntity editedTask,
  );
}
