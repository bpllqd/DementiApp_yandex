import 'package:bloc/bloc.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/features/todo_list/domain/entities/task_entity.dart';
import 'package:equatable/equatable.dart';

part 'todo_list_state.dart';
part 'todo_list_event.dart';

class ToDoListBloc extends Bloc<ToDoListEvent, ToDoListState> {
  bool showCompletedTasks = false;

  ToDoListBloc() : super(ToDoListInitialState()) {
    on<GetTasksEvent>(_getTasks);
    on<DeleteTaskEvent>(_deleteTask);
    on<CompleteTaskEvent>(_completeTask);
    on<ChangeFilterEvent>(_changeFilter);
  }

  List<TaskEntity> tasksFromRepo = [
    const TaskEntity(
        taskID: '1',
        title: 'Пресс качат, и еще качат, и еще качат, и тренироват, и мотивацию паднят, и пресс качат долго качат',
        done: false,
        priority: Priority.high),
    TaskEntity(
        taskID: '2',
        title: 'Бегит',
        done: true,
        priority: Priority.no,
        date: DateTime.now()),
    const TaskEntity(
        taskID: '3', title: 'Туриник', done: false, priority: Priority.low),
    TaskEntity(
        taskID: '4',
        title: 'Анжумания',
        done: false,
        priority: Priority.high,
        date: DateTime.now()),
    const TaskEntity(
        taskID: '5',
        title: 'Пресс качат',
        done: false,
        priority: Priority.high),
    const TaskEntity(
        taskID: '6', title: 'Бегит', done: true, priority: Priority.no),
    TaskEntity(
        taskID: '7',
        title: 'Туриник',
        done: false,
        priority: Priority.low,
        date: DateTime.now()),
    const TaskEntity(
        taskID: '8', title: 'Анжумания', done: false, priority: Priority.high),
    const TaskEntity(
        taskID: '9',
        title: 'Пресс качат',
        done: false,
        priority: Priority.high),
    const TaskEntity(
        taskID: '10', title: 'Бегит', done: true, priority: Priority.no),
    TaskEntity(
        taskID: '11',
        title: 'Туриник',
        done: false,
        priority: Priority.low,
        date: DateTime.now()),
    const TaskEntity(
        taskID: '12', title: 'Анжумания', done: false, priority: Priority.high),
  ];

  Future<void> _getTasks(
      GetTasksEvent event, Emitter<ToDoListState> emit) async {
    emit(ToDoListLoadingState());
    DementiappLogger.infoLog('Loading...');

    int ctr = 0;
    for (int i = 0; i < tasksFromRepo.length; i++) {
      if (tasksFromRepo[i].done) {
        ctr++;
      }
    }

    const Duration(seconds: 2);

    emit(TodoListSuccessState(
      tasks: tasksFromRepo,
      completedTasks: ctr,
    ));
    DementiappLogger.infoLog('Got tasks!');
  }

  Future<void> _deleteTask(
    DeleteTaskEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(ToDoListLoadingState());
    DementiappLogger.infoLog('Loading...');

    for (int i = 0; i < tasksFromRepo.length; i++) {
      if (tasksFromRepo[i].taskID == event.uuid) {
        tasksFromRepo.removeAt(i);
      }
    }

    int ctr = 0;
    for (int i = 0; i < tasksFromRepo.length; i++) {
      if (tasksFromRepo[i].done) {
        ctr++;
      }
    }

    emit(TodoListSuccessState(tasks: tasksFromRepo, completedTasks: ctr));
    DementiappLogger.infoLog('Task has been deleted!');
  }

  Future<void> _completeTask(
    CompleteTaskEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    for (int i = 0; i < tasksFromRepo.length; i++) {
      if (tasksFromRepo[i].taskID == event.task.taskID) {
        tasksFromRepo[i] = tasksFromRepo[i].copyWith(done: !event.task.done);
      }
    }

    int ctr = 0;
    for (int i = 0; i < tasksFromRepo.length; i++) {
      if (tasksFromRepo[i].done) {
        ctr++;
      }
    }

    emit(TodoListSuccessState(tasks: tasksFromRepo, completedTasks: ctr));
    DementiappLogger.infoLog('Task has been completed!');
  }

  void _changeFilter(
    ChangeFilterEvent event,
    Emitter<ToDoListState> emit,
  ) {
    int ctr = 0;
    for (int i = 0; i < tasksFromRepo.length; i++) {
      if (tasksFromRepo[i].done) {
        ctr++;
      }
    }

    emit(TodoListSuccessState(
        tasks: tasksFromRepo, completedTasks: ctr, filter: event.filter));
    DementiappLogger.infoLog('Filter has been changed!');
  }
}
