import 'package:bloc/bloc.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/utils.dart';
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

  Future<void> _getTasks(
    GetTasksEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    //TODO

    DementiappLogger.infoLog('GetTasksEvent done with state: ');
  }

  Future<void> _deleteTask(
    DeleteTaskEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    //TODO

    DementiappLogger.infoLog('DeleteTaskEvent done with state: ');
  }

  Future<void> _completeTask(
    CompleteTaskEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    //TODO

    DementiappLogger.infoLog('CompleteTaskEvent done with state: ');
  }

  void _changeFilter(
    ChangeFilterEvent event,
    Emitter<ToDoListState> emit,
  ) {
    //TODO

    DementiappLogger.infoLog('ChangeFilterEvent done with state: ');
  }
}
