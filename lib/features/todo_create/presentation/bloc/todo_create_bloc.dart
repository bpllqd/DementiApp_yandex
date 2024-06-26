import 'dart:async';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/features/todo_list/domain/entities/task_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'todo_create_state.dart';
part 'todo_create_event.dart';

class ToDoCreateBloc extends Bloc<ToDoCreateEvent, ToDoCreateState> {
  ToDoCreateBloc() : super(ToDoCreateInitState()) {
    on<ToDoCreateInitEvent>(_init);
    on<ToDoCreateNewEvent>(_createTask);
    on<ToDoCreateDeleteEvent>(_deleteTask);
    on<ToDoCreateSwitchDateEvent>(_switchDate);
  }

  void _init(ToDoCreateInitEvent event, Emitter<ToDoCreateState> emit) {
    emit(ToDoCreateSuccessState());
  }

  Future<void> _createTask(
    ToDoCreateNewEvent event,
    Emitter<ToDoCreateState> emit,
  ) async {
    emit(ToDoCreateLoadingState());
    DementiappLogger.infoLog('Loading...');
    const Duration(seconds: 2);

    emit(ToDoCreateSuccessState(
        task: event.task, hasDate: event.task.date != null,),);
    DementiappLogger.infoLog('Task has been created!');
  }

  Future<void> _deleteTask(
    ToDoCreateDeleteEvent event,
    Emitter<ToDoCreateState> emit,
  ) async {
    emit(ToDoCreateLoadingState());
    DementiappLogger.infoLog('Loading...');
    const Duration(seconds: 2);

    emit(ToDoCreateSuccessState(
        task: event.task, hasDate: event.task.date != null,),);
    DementiappLogger.infoLog('Task has been deleted!');
  }

  Future<void> _switchDate(
    ToDoCreateSwitchDateEvent event,
    Emitter<ToDoCreateState> emit,
  ) async {
    emit(ToDoCreateSuccessState(
        task: event.task, hasDate: event.task!.date == null ? false : true,),);
    DementiappLogger.infoLog('DatePicker switch has been switched!');
  }
}
