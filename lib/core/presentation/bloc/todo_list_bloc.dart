import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart';
import 'package:demetiapp/core/data/repositories/to_do_list_repository_impl.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/error/failure.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/core/domain/usecases/todo_create_usecases.dart';
import 'package:demetiapp/core/domain/usecases/todo_list_usecases.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'todo_list_state.dart';
part 'todo_list_event.dart';

class ToDoListBloc extends Bloc<ToDoListEvent, ToDoListState> {
  ToDoListBloc() : super(ToDoListInitState()) {
    on<GetTasksEvent>(_getTasks);
    on<TaskCompleteEvent>(_completeTask);
    on<TaskDeleteEvent>(_deleteTask);
    on<TaskEditEvent>(_editTask);
    on<TaskCreateEvent>(_createTask);
    on<ChangeFilterEvent>(_changeFilter);
    on<TaskEditedSaveEvent>(_saveEditedTask);
    on<TaskCreatedSaveEvent>(_saveCreatedTask);
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

  Future<void> _getTasks(
    GetTasksEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(LoadingState());

    DementiappLogger.infoLog('BLoC:getTasks - loading in _getTasks');

    final GetAllTasks getTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);
    final Either<Failure, List<TaskEntity>> result = await getTasks.call();

    result.fold((failure) {
      emit(ErrorState(errorDescription: failure.message));

      DementiappLogger.errorLog('Got error in BLoC _getTasks ${failure.message}');
    }, (value) {
      emit(
        SuccessState(
          tasks: value,
          completedTasks: value.where((task) => task.done).length,
        ),
      );
      DementiappLogger.infoLog('Got all tasks from BLoC _getTasks!');
    });
  }

  Future<void> _completeTask(
    TaskCompleteEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(LoadingState());
    DementiappLogger.infoLog('Loading from _completeTask');

    final EditTask editTask = EditTask(toDoListRepository: toDoListRepository);
    final GetAllTasks getAllTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);

    final editedTask =
        event.task.copyWith(done: !event.task.done, changedAt: DateTime.now());
    DementiappLogger.infoLog('BLoC:completeTask - completed task $editedTask');

    final Either<Failure, void> result =
        await editTask.call(event.task, editedTask);
    DementiappLogger.infoLog('BLoC:completeTask - task marked as completed');

    await result.fold((failure) {
      emit(ErrorState(errorDescription: failure.message));
      DementiappLogger.errorLog(
        'BLoC:completeTask - error 1 - ${failure.message}',
      );
    }, (value) async {
      final Either<Failure, List<TaskEntity>> resultAll =
          await getAllTasks.call();
      resultAll.fold((failure) {
        DementiappLogger.errorLog(
          'BLoC:completeTask - error 2 - ${failure.message}',
        );        
        emit(ErrorState(errorDescription: failure.message));
      }, (valueGood) {
        DementiappLogger.infoLog('BLoC:completeTask - updated tasks in all sources, emitin success');
        emit(
          SuccessState(
            tasks: valueGood,
            completedTasks: valueGood.where((task) => task.done).length,
          ),
        );
      });
      DementiappLogger.infoLog('Completing task in BLoC _completeTask ended with MEGAHOROSH!');
    });
  }

  Future<void> _deleteTask(
    TaskDeleteEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(LoadingState());
    DementiappLogger.infoLog('BLoC:deleteTask - Loading from delete task');

    final DeleteExactTask deleteTask =
        DeleteExactTask(toDoListRepository: toDoListRepository);
    final GetAllTasks getAllTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);

    final Either<Failure, void> result = await deleteTask.call(event.task);

    await result.fold((failure) {
      emit(ErrorState(errorDescription: failure.message));
      DementiappLogger.errorLog(
        'Got error in BLoC _deleteTask - failure 1 ${failure.message}',
      );
    }, (value) async {
      final Either<Failure, List<TaskEntity>> resultAll =
          await getAllTasks.call();
      resultAll.fold((failure) {
        emit(ErrorState(errorDescription: failure.message));
        DementiappLogger.errorLog(
          'Got error in BLoC _deleteTask - failure 2 ${failure.message}',
        );
      }, (valueGood) {
        emit(
          SuccessState(
            tasks: valueGood,
            completedTasks: valueGood.where((task) => task.done).length,
          ),
        );
        DementiappLogger.infoLog(
          'BLoC _deleteTask completed with MEGAHOROSH',
        );
      });
    });
  }

  Future<void> _editTask(
    TaskEditEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(EditInProgressState(task: event.task));
    DementiappLogger.infoLog('Current state: EditInProgressState');
  }

  Future<void> _createTask(
    TaskCreateEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(CreateInProgressState());
    DementiappLogger.infoLog('Current state: CreateInProgressState');
  }

  void _changeFilter(
    ChangeFilterEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(LoadingState());
    DementiappLogger.infoLog('Loading from _changeFilter');

    emit(
      SuccessState(
        tasks: event.tasks,
        completedTasks: event.completedTasks,
        filter:
            event.filter == true ? TasksFilter.showOnly : TasksFilter.showAll,
      ),
    );

    DementiappLogger.infoLog('Changed filter to ${event.filter}!');
  }

  Future<void> _saveEditedTask(
    TaskEditedSaveEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(LoadingState());
    DementiappLogger.infoLog('Loading from _saveEditedTask');

    final EditTask editTask = EditTask(toDoListRepository: toDoListRepository);

    final Either<Failure, void> result =
        await editTask.call(event.oldTask, event.newTask);

    result.fold((failure) {
      DementiappLogger.errorLog(
        'Got error in BLoC saveEditedTask 1 ${failure.message}',
      );
      emit(ErrorState(errorDescription: failure.message));
    }, (value) {
      DementiappLogger.infoLog('Editing in BLoC saveEditedTask ended with MEGAHOROSH!');
      emit(EditingSuccessState());
    });
  }

  Future<void> _saveCreatedTask(
    TaskCreatedSaveEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(LoadingState());
    DementiappLogger.infoLog('BLoC:_saveCreatedTask - loading');

    final CreateTask createTask =
        CreateTask(toDoListRepository: toDoListRepository);

    final Either<Failure, void> result = await createTask.call(event.task);

    result.fold((failure) {
      DementiappLogger.errorLog(
        'Got error in BLoC _saveCreatedTask 1 ${failure.message}',
      );
      emit(ErrorState(errorDescription: failure.message));
    }, (value) {
      DementiappLogger.infoLog('Creating in BLoC saveCreatedTask ended with MEGAHOROSH!');
      emit(CreatingSuccessState());
    });
  }
}