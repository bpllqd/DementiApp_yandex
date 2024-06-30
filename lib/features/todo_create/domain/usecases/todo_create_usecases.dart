import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/domain/repository/todo_list_repository.dart';
import 'package:demetiapp/core/error/failure.dart';

class CreateTask {
  final ToDoListRepository toDoListRepository;

  CreateTask({required this.toDoListRepository});

  Future<Either<Failure, void>> call(TaskEntity task) async {
    return await toDoListRepository.createTask(task);
  }
}

class EditTask {
  final ToDoListRepository toDoListRepository;

  EditTask({required this.toDoListRepository});

  Future<Either<Failure, void>> call(
      TaskEntity oldTask, TaskEntity editedTask,) async {
    return await toDoListRepository.editTask(oldTask, editedTask);
  }
}
