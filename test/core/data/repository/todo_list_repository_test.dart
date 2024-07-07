import 'package:dartz/dartz.dart';
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart';
import 'package:demetiapp/core/data/dto/task_local_dto.dart';
import 'package:demetiapp/core/data/repositories/to_do_list_repository_impl.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/error/failure.dart';
import 'package:demetiapp/core/utils/network_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main(){
  late TaskLocalDataSourceMock taskLocalDataSourceMock;
  late TaskRemoteDataSourceMock taskRemoteDataSourceMock;
  late NetworkStatusMock networkStatusMock;
  late ToDoListRepositoryMock toDoListRepositoryMock;
  late ToDoListRepositoryImpl toDoListRepository;

  setUpAll(() {
    registerFallbackValue(FallbackTaskLocalModel());
    
  });

  setUp((){
    taskLocalDataSourceMock = TaskLocalDataSourceMock();
    when(()=> taskLocalDataSourceMock.createTaskToCache(any(that: isA<TaskLocalModel>()))).thenAnswer((_) async => 1);

    taskRemoteDataSourceMock = TaskRemoteDataSourceMock();

    networkStatusMock = NetworkStatusMock();
    when(()=>networkStatusMock.isOnline).thenReturn(true);

    toDoListRepositoryMock = ToDoListRepositoryMock();
    when(() => toDoListRepositoryMock.getId()).thenAnswer((_) async => 'test');

    toDoListRepository = ToDoListRepositoryImpl(
      db: taskLocalDataSourceMock,
      api: taskRemoteDataSourceMock,
      networkStatus: networkStatusMock,
    );
  });

  group('ToDo repository', (){
    group('с методом createTaskToCache', (){
      TaskLocalModel expectedTask = TaskLocalModel(
        id: '1',
        text: 'Stab',
        importance: 'basic',
        done: false,
        lastUpdatedBy: 'test',
        changedAt: DateTime.utc(2023, 01, 02),
        createdAt: DateTime.utc(2023, 01, 01),);
      test('должен выполнять запрос к Local Datasource с правильными параметрами', () async{
        //arange

        //act
        await toDoListRepository.createTask(expectedTask);

        //assert
        final verification = verify(()=>taskLocalDataSourceMock.createTaskToCache(captureAny())).captured;

        expect(verification.first.runtimeType, expectedTask.runtimeType);
      });

      test('должен выполнять запрос к Local Datasource и вносить новую запись', () async{
        //arange
        when(() => taskLocalDataSourceMock.createTaskToCache(any(that: isA<TaskLocalModel>())))
            .thenAnswer((_) async => 1);

        //act
        final result = await toDoListRepository.createTask(expectedTask);

        //assert
        expect(result, const Right(null));
      });

      test('должен возвращать CacheFailure при CacheException', () async{
        //arrange
        when(() => taskLocalDataSourceMock.createTaskToCache(any(that: isA<TaskLocalModel>())))
            .thenThrow(CacheException('Cache Error'));

        //act
        final result = await toDoListRepository.createTask(expectedTask);

        // assert
        expect(result, const Left(CacheFailure('Cache Error')));
      });

      test('должен возвращать Failure при любом другом исключении', () async{
        //arrange
        when(()=> taskLocalDataSourceMock.createTaskToCache(any(that: isA<TaskLocalModel>()))).thenThrow(Exception('Other exception'));

        //act
        final result = await toDoListRepository.createTask(expectedTask);

        //assert
        expect(result, const Left(Failure('Other exception')));
      });
    });
  });
}

///  Моки
class TaskLocalDataSourceMock extends Mock implements TaskLocalDataSource{}
class TaskRemoteDataSourceMock extends Mock implements TaskRemoteDataSource{}
class NetworkStatusMock extends Mock implements NetworkStatus{}
class ToDoListRepositoryMock extends Mock implements ToDoListRepositoryImpl {}


// Фейки (не лэймы)
class FallbackTaskLocalModel extends Fake implements TaskLocalModel{}
