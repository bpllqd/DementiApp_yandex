import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/error/failure.dart';

abstract class ToDoListRepository {
  Future<Either<Failure, List<TaskEntity>>> getAllTasks(); //GET $BASEURL/list

  Future<Either<Failure, void>> updateAllTasks(
    int revision,
  ); //PATCH $BASEURL/list

  Future<Either<Failure, void>> deleteTask(
    String id,
  ); // DELETE $BASEURL/list/<id>

  Future<Either<Failure, TaskEntity>> getExactTask(
    String id,
  ); //GET $BASEURL/list/<id>

  Future<Either<Failure, void>> deleteExactTask(
    String id,
  ); //DELETE $BASEURL/list/<id>

  Future<Either<Failure, void>> createTask(
    TaskEntity task,
    int revision,
  ); //DELETE $BASEURL/list/<id>

  Future<Either<Failure, void>> editTask(
    String id,
    TaskEntity editedTask,
  ); // PUT $BASEURL/list/<id>
}
