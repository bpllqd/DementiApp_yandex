import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/domain/repository/todo_list_repository.dart';
import 'package:demetiapp/core/error/failure.dart';

class GetAllTasks {
  final ToDoListRepository toDoListRepository;

  GetAllTasks({required this.toDoListRepository});

  Future<Either<Failure, List<TaskEntity>>> call() async {
    return await toDoListRepository.getAllTasks();
  }
}

class UpdateAllTasks {
  final ToDoListRepository toDoListRepository;

  UpdateAllTasks({required this.toDoListRepository});

  Future<Either<Failure, void>> call(
    List<TaskEntity> tasks,
    int revision,
  ) async {
    return await toDoListRepository.updateAllTasks(tasks, revision);
  }
}

class DeleteTask {
  final ToDoListRepository toDoListRepository;

  DeleteTask({required this.toDoListRepository});

  Future<Either<Failure, void>> call(TaskEntity task) async {
    return await toDoListRepository.deleteTask(task);
  }
}

class GetExactTask {
  final ToDoListRepository toDoListRepository;

  GetExactTask({required this.toDoListRepository});

  Future<Either<Failure, TaskEntity>> call(TaskEntity task) async {
    return await toDoListRepository.getExactTask(task);
  }
}

class DeleteExactTask {
  final ToDoListRepository toDoListRepository;

  DeleteExactTask({required this.toDoListRepository});

  Future<Either<Failure, void>> call(TaskEntity task) async {
    return await toDoListRepository.deleteTask(task);
  }
}
