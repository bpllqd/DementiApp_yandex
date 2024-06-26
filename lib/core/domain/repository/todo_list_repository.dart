import 'package:demetiapp/core/domain/entities/task_entity.dart';

abstract class ToDoListRepository {
  Future<List<TaskEntity>> getAllTasks(); //GET $BASEURL/list 

  Future<> updateAllTasks(int revision); //PATCH $BASEURL/list

  Future<> deleteTask(String id); // DELETE $BASEURL/list/<id>

  Future<TaskEntity> getExactTask(String id); //GET $BASEURL/list/<id>

  Future<> deleteExactTask(String id); //DELETE $BASEURL/list/<id>

  Future<> createTask(TaskEntity task, int revision); //DELETE $BASEURL/list/<id>

  Future<> editTask(String id, TaskEntity editedTask); // PUT $BASEURL/list/<id>
}