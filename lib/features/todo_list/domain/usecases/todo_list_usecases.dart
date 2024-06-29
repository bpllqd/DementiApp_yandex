import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/domain/repository/todo_list_repository.dart';
import 'package:demetiapp/core/error/failure.dart';

class GetAllTasks {
  final ToDoListRepository toDoListrepository;

  GetAllTasks({required this.toDoListrepository});

  Future<Either<Failure, List<TaskEntity>>> call() async {
    return await toDoListrepository.getAllTasks();
  }
}

class UpdateAllTasks {
  final ToDoListRepository toDoListrepository;

  UpdateAllTasks({required this.toDoListrepository});

  Future<Either<Failure, void>> call(List<TaskEntity> tasks, int revision) async {
    return await toDoListrepository.updateAllTasks(tasks, revision);
  }
}

class DeleteTask {
  final ToDoListRepository toDoListrepository;

  DeleteTask({required this.toDoListrepository});

  Future<Either<Failure, void>> call(TaskEntity task) async {
    return await toDoListrepository.deleteTask(task);
  }
}

class GetExactTask {
  final ToDoListRepository toDoListrepository;

  GetExactTask({required this.toDoListrepository});

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) async {
    return await toDoListrepository.getExactTask(task);
  }
}

class DeleteExactTask {
  final ToDoListRepository toDoListrepository;

  DeleteExactTask({required this.toDoListrepository});

  Future<Either<Failure, void>> call(TaskEntity task) async {
    return await toDoListrepository.deleteTask(task);
  }
}
