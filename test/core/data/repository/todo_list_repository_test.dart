import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart';
import 'package:demetiapp/core/data/dto/task_api_dto.dart';
import 'package:demetiapp/core/data/dto/task_local_dto.dart';
import 'package:demetiapp/core/data/dto/task_mapper.dart';
import 'package:demetiapp/core/data/repositories/to_do_list_repository_impl.dart';
import 'package:demetiapp/core/domain/entities/task_entity.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/error/failure.dart';
import 'package:demetiapp/core/utils/network_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

///  Моки
class TaskLocalDataSourceMock extends Mock implements TaskLocalDataSource {}

class TaskRemoteDataSourceMock extends Mock implements TaskRemoteDataSource {}

class NetworkStatusMock extends Mock implements NetworkStatus {}

class ToDoListRepositoryMock extends Mock implements ToDoListRepositoryImpl {}

// Фейки (не лэймы)
class FallbackTaskLocalModel extends Fake implements TaskLocalModel {}

void main() {
  late TaskLocalDataSourceMock taskLocalDataSourceMock;
  late TaskRemoteDataSourceMock taskRemoteDataSourceMock;
  late NetworkStatusMock networkStatusMock;
  late ToDoListRepositoryMock toDoListRepositoryMock;
  late ToDoListRepositoryImpl toDoListRepository;

  setUpAll(() {
    registerFallbackValue(FallbackTaskLocalModel());
  });

  setUp(() {
    taskLocalDataSourceMock = TaskLocalDataSourceMock();

    taskRemoteDataSourceMock = TaskRemoteDataSourceMock();

    networkStatusMock = NetworkStatusMock();

    toDoListRepositoryMock = ToDoListRepositoryMock();
    when(() => toDoListRepositoryMock.getId()).thenAnswer((_) async => 'test');

    toDoListRepository = ToDoListRepositoryImpl(
      db: taskLocalDataSourceMock,
      api: taskRemoteDataSourceMock,
      networkStatus: networkStatusMock,
    );
  });

  group('ToDo repository', () {
    final taskLocalModel = [
      TaskLocalModel(
        id: '1',
        text: 'getAll',
        importance: 'basic',
        done: false,
        lastUpdatedBy: 'test',
        changedAt: DateTime.utc(2023, 01, 02),
        createdAt: DateTime.utc(2023, 01, 01),
      ),
    ];
    final taskApiModel = [
      TaskApiModel(
        id: '1',
        text: 'getAll',
        importance: 'basic',
        done: false,
        lastUpdatedBy: 'test',
        changedAt: DateTime.utc(2023, 01, 02),
        createdAt: DateTime.utc(2023, 01, 01),
      ),
    ];
    final taskEntities = TaskMapper.toEntityListFromLocal(taskLocalModel);
    final localResult =
        TaskLocalModelWithRevision(listTasks: taskLocalModel, localRevision: 1);
    final apiResult = TaskApiModelWithRevision(listTasks: [], apiRevision: 1);
    group('и его метод createTaskToCache', () {
      TaskLocalModel expectedTask = TaskLocalModel(
        id: '1',
        text: 'Stab',
        importance: 'basic',
        done: false,
        lastUpdatedBy: 'test',
        changedAt: DateTime.utc(2023, 01, 02),
        createdAt: DateTime.utc(2023, 01, 01),
      );
      test(
          'должен выполнять запрос к Local Datasource с правильными параметрами',
          () async {
        //arange
        when(
          () => taskLocalDataSourceMock.createTaskToCache(
            any(that: isA<TaskLocalModel>()),
          ),
        ).thenAnswer((_) async => 1);

        //act
        await toDoListRepository.createTask(expectedTask);

        //assert
        final verification = verify(
          () => taskLocalDataSourceMock.createTaskToCache(captureAny()),
        ).captured;

        expect(verification.first.runtimeType, expectedTask.runtimeType);
      });

      test('должен выполнять запрос к Local Datasource и вносить новую запись',
          () async {
        //arange

        when(() => taskLocalDataSourceMock.createTaskToCache(any()))
            .thenAnswer((_) async {});
        //act
        final result = await toDoListRepository.createTask(expectedTask);

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, const Right(null));
      });

      test('должен возвращать CacheFailure при ошибке Local Datasource',
          () async {
        //arrange
        when(
          () => taskLocalDataSourceMock
              .createTaskToCache(any(that: isA<TaskLocalModel>())),
        ).thenThrow(CacheException('Cache Error'));

        //act
        final result = await toDoListRepository.createTask(expectedTask);

        // assert
        // ignore: inference_failure_on_instance_creation
        expect(result, const Left(CacheFailure('Cache Error')));
      });

      test('должен возвращать Failure при ошибке репозитория', () async {
        //arrange
        when(
          () => taskLocalDataSourceMock
              .createTaskToCache(any(that: isA<TaskLocalModel>())),
        ).thenThrow(Exception('Other exception'));

        //act
        final result = await toDoListRepository.createTask(expectedTask);

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, const Left(Failure('Other exception')));
      });
    });

    group('и его метод getAllTasks', () {
      test('должен возвращать список задач из Local при отсутствии интернета',
          () async {
        //arrange
        when(() => networkStatusMock.isOnline).thenReturn(false);
        when(() => taskLocalDataSourceMock.getAllTasksFromCache())
            .thenAnswer((_) async => localResult);

        //act
        final result = await toDoListRepository.getAllTasks();

        //assert
        verify(() => taskLocalDataSourceMock.getAllTasksFromCache());
        // ignore: strict_raw_type
        expect(result, isA<Right>());
      });

      test(
          'должен обновлять список задач в api (синхронизироваться) при наличии* интернета',
          () async {
        //arrange
        when(() => networkStatusMock.isOnline).thenReturn(true);
        when(() => taskLocalDataSourceMock.getAllTasksFromCache())
            .thenAnswer((_) async => localResult);
        when(() => taskRemoteDataSourceMock.getAllTasks())
            .thenAnswer((_) async => apiResult);
        when(() => taskRemoteDataSourceMock.updateAllTasks(any(), any()))
            .thenAnswer((_) async => apiResult);

        //act
        await toDoListRepository.getAllTasks();

        //assert
        verify(() => taskRemoteDataSourceMock.getAllTasks()).called(1);
        verify(
          () => taskLocalDataSourceMock
              .updateLocalRevision(apiResult.apiRevision),
        ).called(1);
        verify(() => taskLocalDataSourceMock.getAllTasksFromCache()).called(1);
        verify(
          () => taskRemoteDataSourceMock.updateAllTasks(
            taskApiModel,
            apiResult.apiRevision,
          ),
        ).called(1);
      });

      test('должен возвращать CacheFailure, если случится CacheException',
          () async {
        //arrange
        when(() => networkStatusMock.isOnline).thenReturn(false);
        when(() => taskLocalDataSourceMock.getAllTasksFromCache())
            .thenThrow(CacheException('cache exception'));

        //act
        final result = await toDoListRepository.getAllTasks();

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, equals(const Left(CacheFailure('cache exception'))));
      });

      test('должен возвращать ServerFailure, если api выбросит ошибку',
          () async {
        //arrange
        when(() => networkStatusMock.isOnline).thenReturn(true);
        when(() => taskRemoteDataSourceMock.getAllTasks())
            .thenThrow(ServerException('server exception'));

        //act
        final result = await toDoListRepository.getAllTasks();

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, equals(const Left(ServerFailure('server exception'))));
      });

      test('должен возвращать Failure при ошибке репозитория', () async {
        //arrange
        when(() => networkStatusMock.isOnline).thenReturn(true);
        when(() => toDoListRepositoryMock.getAllTasks())
            .thenThrow(Exception('repo exception'));

        //act
        final result = await toDoListRepository.getAllTasks();

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, equals(const Left(Failure('repo exception'))));
      });
    });

    group('и его метод updateAllTasks', () {
      final taskLocalModel = [
        TaskLocalModel(
          id: '1',
          text: 'updateAll',
          importance: 'basic',
          done: false,
          lastUpdatedBy: 'test',
          changedAt: DateTime.utc(2023, 01, 02),
          createdAt: DateTime.utc(2023, 01, 01),
        ),
      ];
      final taskLocalResult = TaskLocalModelWithRevision(
        listTasks: taskLocalModel,
        localRevision: 1,
      );
      final taskEntity = [
        TaskEntity(
          id: '1',
          text: 'updateAll',
          done: false,
          importance: 'basic',
          lastUpdatedBy: 'test',
          changedAt: DateTime.utc(2023, 01, 02),
          createdAt: DateTime.utc(2023, 01, 01),
        ),
      ];
      test('должен обновлять Local задачи на новые', () async {
        //arrange
        when(
          () => taskLocalDataSourceMock.updateAllTasksToCache(taskLocalModel),
        ).thenAnswer((_) async => taskLocalResult);

        //act
        final result = await toDoListRepository.updateAllTasks(taskEntity);

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, equals(const Right(null)));
      });

      test('должен возвращать CacheFailure при ошибке Local', () async {
        //arrange
        when(
          () => taskLocalDataSourceMock.updateAllTasksToCache(taskLocalModel),
        ).thenThrow(CacheException('cache exception'));

        //act
        final result = await toDoListRepository.updateAllTasks(taskEntity);

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, equals(const Left(CacheFailure('cache exception'))));
      });

      test('должен возвращать Failure при ошибке самого репозитория', () async {
        //arrange
        when(() => toDoListRepositoryMock.updateAllTasks(taskEntity))
            .thenThrow(Exception('repo exception'));

        //act
        final result = await toDoListRepository.updateAllTasks(taskEntity);

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, equals(const Left(Failure('repo exception'))));
      });
    });

    group('и его метод deleteTask', () {
      test('должен возвращать Right при успешном удалении из Local', () async {
        //arrange
        when(
          () => taskLocalDataSourceMock.deleteExactTaskFromCache(
            taskLocalModel.first,
          ),
        ).thenAnswer((_) async {});
        //act
        final result = await toDoListRepository.deleteTask(taskEntities.first);

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, equals(const Right(null)));
      });

      test('должен возвращать CacheFailure при ошибке удаления в Local',
          () async {
        //arrange
        when(
          () => taskLocalDataSourceMock.deleteExactTaskFromCache(
            taskLocalModel.first,
          ),
        ).thenThrow(CacheException('local error'));

        //act
        final result = await toDoListRepository.deleteTask(taskEntities.first);

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, equals(const Left(CacheFailure('local error'))));
      });

      test('должен возвращать Failure при ошибке репо', () async {
        //arrange
        when(() => toDoListRepositoryMock.deleteTask(taskEntities.first))
            .thenThrow(Exception('repo error'));

        //act
        final result = await toDoListRepository.deleteTask(taskEntities.first);

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, const Left(Failure('repo error')));
      });
    });

    group('и его метод getExactTaak', () {
      test('должен вернуть запрошенную задачу из Local', () async {
        //arrange
        when(
          () => taskLocalDataSourceMock.getExactTaskFromCache(
            taskLocalModel.first,
          ),
        ).thenAnswer((_) async => localResult);

        //act
        final result =
            await toDoListRepository.getExactTask(taskEntities.first);

        //assert
        // ignore: strict_raw_type
        expect(result, isA<Right>());
        expect(
          result.fold((failure) => null, (task) => task),
          isA<TaskEntity>(),
        );
      });

      test('должен возвращать CacheFailure при ошибке Local', () async {
        //arrange
        when(
          () => taskLocalDataSourceMock.getExactTaskFromCache(
            taskLocalModel.first,
          ),
        ).thenThrow(CacheException('local error'));

        //act
        final result =
            await toDoListRepository.getExactTask(taskEntities.first);

        //assert
        // ignore: strict_raw_type
        expect(result, isA<Left>());
        expect(
          result.fold((failure) => failure, (value) => null),
          isA<CacheFailure>(),
        );
      });

      test('должен возвращать Failure при ошибке репо', () async {
        //arrange
        when(() => toDoListRepositoryMock.getExactTask(taskEntities.first))
            .thenThrow(Exception('repo error'));

        //act
        final result =
            await toDoListRepository.getExactTask(taskEntities.first);

        //assert
        // ignore: strict_raw_type
        expect(result, isA<Left>());
        expect(
          result.fold((failure) => failure, (value) => null),
          isA<Failure>(),
        );
      });
    });

    group('и его метод editTask', () {
      test('должен возвращать Right в случае успешного редактировани',
          () async {
        //arrange
        when(() => taskLocalDataSourceMock.editTaskToCache(any(), any()))
            .thenAnswer((_) async => localResult);

        //act
        final result = await toDoListRepository.editTask(
          taskEntities.first,
          taskEntities.first,
        );

        //assert
        // ignore: inference_failure_on_instance_creation
        expect(result, equals(const Right(null)));
      });

      test('должен возвращать CacheFailure при ошибке в Local', () async {
        //arrange
        when(() => taskLocalDataSourceMock.editTaskToCache(any(), any()))
            .thenThrow(CacheException('local error'));

        //act
        final result = await toDoListRepository.editTask(
          taskEntities.first,
          taskEntities.first,
        );

        //assert
        // ignore: strict_raw_type
        expect(result, isA<Left>());
        expect(
          result.fold((failure) => failure, (value) => null),
          isA<CacheFailure>(),
        );
      });

      test('должен возвращать Failure при ошибке репозитория', () async {
        //arrange
        when(() => toDoListRepositoryMock.editTask(any(), any()))
            .thenThrow(Exception('repo error'));

        //act
        final result = await toDoListRepository.editTask(
          taskEntities.first,
          taskEntities.first,
        );

        //assert
        // ignore: strict_raw_type
        expect(result, isA<Left>());
        expect(
          result.fold((failure) => failure, (value) => null),
          isA<Failure>(),
        );
      });
    });
  });
}
