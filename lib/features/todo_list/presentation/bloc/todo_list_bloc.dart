import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart';
import 'package:demetiapp/core/data/repositories/to_do_list_repository_impl.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/error/failure.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:demetiapp/core/utils/utils.dart';
import 'package:demetiapp/features/todo_create/domain/usecases/todo_create_usecases.dart';
import 'package:demetiapp/features/todo_list/domain/usecases/todo_list_usecases.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'todo_list_state.dart';
part 'todo_list_event.dart';

class ToDoListBloc extends Bloc<ToDoListEvent, ToDoListState> {
  bool showCompletedTasks = false;

  ToDoListBloc() : super(ToDoListInitialState()) {
    on<GetTasksEvent>(_getTasks);
    on<DeleteTaskEvent>(_deleteTask);
    on<CreateNavigateTaskEvent>(_createNavigateTask);
    on<EditNavigateTaskEvent>(_editNavigateTask);
    on<CompleteTaskEvent>(_completeTask);
    on<UnCompleteTaskEvent>(_uncompleteTask);
    on<ChangeFilterEvent>(_changeFilter);
    on<ToDoCreateNewEvent>(_createTask);
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

  Future<void> _getTasks(
    GetTasksEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(ToDoListLoadingState());
    final GetAllTasks getTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);
    final Either<Failure, List<TaskEntity>> result = await getTasks.call();

    result.fold((failure) {
      emit(ToDoListErrorState(errorDescription: failure.message));
    }, (value) {
      emit(TodoListSuccessState(
          tasks: value,
          completedTasks: value.where((task) => task.done).length,),);
    });

    DementiappLogger.infoLog('GetTasksEvent done with state: ');
  }

  Future<void> _deleteTask(
    DeleteTaskEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(ToDoListLoadingState());
    final DeleteExactTask deleteTask =
        DeleteExactTask(toDoListRepository: toDoListRepository);
    final GetAllTasks getAllTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);
    final Either<Failure, void> result = await deleteTask.call(event.task);

    result.fold((failure) {
      emit(ToDoListErrorState(errorDescription: failure.message));
    }, (value) async {
      final Either<Failure, List<TaskEntity>> resultAll =
          await getAllTasks.call();
      resultAll.fold((failure) {
        emit(ToDoListErrorState(errorDescription: failure.message));
      }, (valueGood) {
        emit(TodoListSuccessState(
            tasks: valueGood,
            completedTasks: valueGood.where((task) => task.done).length,),);
      });
    });
    DementiappLogger.infoLog('DeleteTaskEvent done with state: ');
  }

  Future<void> _completeTask(
    CompleteTaskEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(ToDoListLoadingState());
    final EditTask editTask = EditTask(toDoListRepository: toDoListRepository);
    final GetAllTasks getAllTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);
    final editedTask =
        event.task.copyWith(done: true, changedAt: DateTime.now());

    final Either<Failure, void> result =
        await editTask.call(event.task, editedTask);

    result.fold((failure) {
      emit(ToDoListErrorState(errorDescription: failure.message));
    }, (value) async {
      final Either<Failure, List<TaskEntity>> resultAll =
          await getAllTasks.call();
      resultAll.fold((failure) {
        emit(ToDoListErrorState(errorDescription: failure.message));
      }, (valueGood) {
        emit(TodoListSuccessState(
            tasks: valueGood,
            completedTasks: valueGood.where((task) => task.done).length,),);
      });
    });

    DementiappLogger.infoLog('CompleteTaskEvent done with state: ');
  }

  Future<void> _uncompleteTask(
    UnCompleteTaskEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(ToDoListLoadingState());
    final EditTask editTask = EditTask(toDoListRepository: toDoListRepository);
    final GetAllTasks getAllTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);
    final editedTask =
        event.task.copyWith(done: false, changedAt: DateTime.now());

    final Either<Failure, void> result =
        await editTask.call(event.task, editedTask);

    result.fold((failure) {
      emit(ToDoListErrorState(errorDescription: failure.message));
    }, (value) async {
      final Either<Failure, List<TaskEntity>> resultAll =
          await getAllTasks.call();
      resultAll.fold((failure) {
        emit(ToDoListErrorState(errorDescription: failure.message));
      }, (valueGood) {
        emit(TodoListSuccessState(
            tasks: valueGood,
            completedTasks: valueGood.where((task) => task.done).length,),);
      });
    });

    DementiappLogger.infoLog('CompleteTaskEvent done with state: ');
  }

  void _changeFilter(
    ChangeFilterEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    final GetAllTasks getAllTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);
    final Either<Failure, List<TaskEntity>> result = await getAllTasks.call();

    result.fold((failure) {
      emit(ToDoListErrorState(errorDescription: failure.message));
    }, (value) {
      emit(
        TodoListSuccessState(
          tasks: value,
          completedTasks: value.where((task) => task.done).length,
          filter: event.filter ? TasksFilter.showOnly : TasksFilter.showAll,
        ),
      );
    });

    DementiappLogger.infoLog('ChangeFilterEvent done with state: ');
  }

  void _editNavigateTask(
    EditNavigateTaskEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(ToDoListEditTaskState(task: event.task));
  }

  void _createNavigateTask(
    CreateNavigateTaskEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(ToDoListCreateTaskState());
  }

  Future<void> _createTask(
    ToDoCreateNewEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(ToDoListLoadingState());

    final CreateTask createTask =
        CreateTask(toDoListRepository: toDoListRepository);
    final GetAllTasks getAllTasks =
        GetAllTasks(toDoListRepository: toDoListRepository);
    final task = event.task
        .copyWith(changedAt: DateTime.now(), createdAt: DateTime.now());
    print('Дополнили модель: $task');

    final Either<Failure, void> result = await createTask.call(task);
    ('Создали на бэке: $result');

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

  Future<void> _editTask(
    ToDoCreateEditEvent event,
    Emitter<ToDoListState> emit,
  ) async {
    emit(ToDoListLoadingState());
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
