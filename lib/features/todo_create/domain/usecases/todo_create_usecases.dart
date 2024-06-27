import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/domain/repository/todo_list_repository.dart';
import 'package:demetiapp/core/error/failure.dart';

class CreateTask {
  final ToDoListRepository toDoListrepository;

  CreateTask({required this.toDoListrepository});

  Future<Either<Failure, void>> call(TaskEntity task, int revision) async {
    return await toDoListrepository.createTask(task, revision);
  }
}

class EditTask {
  final ToDoListRepository toDoListrepository;

  EditTask({required this.toDoListrepository});

  Future<Either<Failure, void>> call(String id, TaskEntity editedTask) async {
    return await toDoListrepository.editTask(id, editedTask);
  }
}
