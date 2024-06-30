import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart';
import 'package:demetiapp/core/data/repositories/to_do_list_repository_impl.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/error/failure.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/features/todo_create/domain/usecases/todo_create_usecases.dart';
import 'package:demetiapp/features/todo_list/domain/usecases/todo_list_usecases.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'todo_create_state.dart';
part 'todo_create_event.dart';

class ToDoCreateBloc extends Bloc<ToDoCreateEvent, ToDoCreateState> {
  ToDoCreateBloc() : super(ToDoCreateInitState()) {
    on<ToDoCreateInitEvent>(_init);
    on<ToDoCreateNewEvent>(_createTask);
    on<ToDoCreateDeleteEvent>(_deleteTask);
    on<ToDoCreateEditEvent>(_editTask);
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://beta.mrdekk.ru/todo',
      headers: {'Authorization': 'Bearer Gilthoniel'},
    ),
  );

  final TaskLocalDatasourceImpl db = TaskLocalDatasourceImpl();
  late final TaskRemoteDataSourceImpl api = TaskRemoteDataSourceImpl(dio: dio);
  late final ToDoListRepositoryImpl toDoListRepository =
      ToDoListRepositoryImpl(db: db, api: api);

  void _init(ToDoCreateInitEvent event, Emitter<ToDoCreateState> emit) {
    emit(ToDoCreateSuccessState());
  }

  Future<void> _createTask(
    ToDoCreateNewEvent event,
    Emitter<ToDoCreateState> emit,
  ) async {
    emit(ToDoCreateLoadingState());

    final CreateTask createTask =
        CreateTask(toDoListRepository: toDoListRepository);
    final GetAllTasks getAllTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);
    final task = event.task
        .copyWith(changedAt: DateTime.now(), createdAt: DateTime.now());

    final Either<Failure, void> result = await createTask.call(task);

    result.fold((failure) {
      emit(ToDoCreateErrorState(errorDescription: failure.message));
    }, (value) async {
      final Either<Failure, List<TaskEntity>> resultAll =
          await getAllTasks.call();
      resultAll.fold((failure) {
        emit(ToDoCreateErrorState(errorDescription: failure.message));
      }, (valueGood) {
        emit(ToDoCreateSuccessState());
      });
    });

    DementiappLogger.infoLog('Task has been created!');
  }

  Future<void> _deleteTask(
    ToDoCreateDeleteEvent event,
    Emitter<ToDoCreateState> emit,
  ) async {
    emit(ToDoCreateLoadingState());
    final DeleteTask deleteTask =
        DeleteTask(toDoListRepository: toDoListRepository);
    final Either<Failure, void> result = await deleteTask.call(event.task);

    result.fold((failure) {
      emit(ToDoCreateErrorState(errorDescription: failure.message));
    }, (value) {
      emit(ToDoCreateSuccessState());
    });
    DementiappLogger.infoLog('Task has been deleted!');
  }

  Future<void> _editTask(
    ToDoCreateEditEvent event,
    Emitter<ToDoCreateState> emit,
  ) async {
    emit(ToDoCreateLoadingState());
    final EditTask editTask = EditTask(toDoListRepository: toDoListRepository);
    final editedTask = event.task.copyWith(changedAt: DateTime.now());

    final Either<Failure, void> result =
        await editTask.call(event.task, editedTask);

    result.fold((failure) {
      emit(ToDoCreateErrorState(errorDescription: failure.message));
    }, (value) async {
      emit(ToDoCreateSuccessState());
    });

    DementiappLogger.infoLog('CompleteTaskEvent done with state: ');
  }
}
