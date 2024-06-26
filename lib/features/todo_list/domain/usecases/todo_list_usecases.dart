import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/domain/repository/todo_list_repository.dart';

class GetAllTasks {
  final ToDoListRepository toDoListrepository;

  GetAllTasks({required this.toDoListrepository});

  Future<List<TaskEntity>> call() async{
    return await toDoListrepository.getAllTasks();
  }
}

class UpdateAllTasks{
  final ToDoListRepository toDoListrepository;

  UpdateAllTasks({required this.toDoListrepository});

  Future<> call(int revision) async{
    return await toDoListrepository.updateAllTasks(revision);
  }
}

class DeleteTask{
  final ToDoListRepository toDoListrepository;

  DeleteTask({required this.toDoListrepository});

  Future<> call(String id) async{
    return await toDoListrepository.deleteTask(id);
  }
}

class GetExactTask{
  final ToDoListRepository toDoListrepository;

  GetExactTask({required this.toDoListrepository});

  Future<TaskEntity> call(String id) async{
    return await toDoListrepository.getExactTask(id);
  }
}

class DeleteExactTask{
  final ToDoListRepository toDoListrepository;

  DeleteExactTask({required this.toDoListrepository});

  Future<> call(String id) async{
    return await toDoListrepository.deleteExactTask(id);
  }
}
