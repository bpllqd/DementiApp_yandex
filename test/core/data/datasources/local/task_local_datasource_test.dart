import 'package:demetiapp/core/data/datasources/local/database_helper.dart';
import 'package:demetiapp/core/data/datasources/local/database_mapper.dart';
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/dto/task_local_dto.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:demetiapp/core/utils/logger/dementiapp_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

// Мок для DBHelper
class MockDBHelper extends Mock implements DatabaseHelper {}

// Мок для Database
class MockDatabase extends Mock implements Database {}

// Мок для DementiappLogger
class MockDementiappLogger extends Mock implements DementiappLogger {}

void main() {
  late TaskLocalDatasourceImpl localDataSource;
  late MockDBHelper mockDBHelper;
  late MockDatabase mockDatabase;
  late MockDementiappLogger mockDementiappLogger;

  setUp(() {
    mockDBHelper = MockDBHelper();
    mockDatabase = MockDatabase();
    mockDementiappLogger = MockDementiappLogger();

    // Замена реального объекта DBHelper на мок
    when(() => mockDBHelper.database).thenAnswer((_) async => mockDatabase);

    localDataSource = TaskLocalDatasourceImpl(databaseHelper: mockDBHelper);
  });

  group('TaskLocalDatasource', (){
    final taskLocalModel = TaskLocalModel(id: '1', text: 'text', importance: 'basic', done: false, lastUpdatedBy: 'test', changedAt: DateTime.utc(2023, 01, 02), createdAt: DateTime.utc(2023, 01, 01));
    final localResult = TaskLocalModelWithRevision(listTasks: [taskLocalModel], localRevision: 1);
    final localRevision = 1;
    final List<Map<String, dynamic>> dbResult = [taskLocalModel.toJson()];
    group('и его метод ceateTaskToCache', (){
      test('должен успешно добавлять новую задачу', ()async{
        //arrange
        when(()=>mockDatabase.insert('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()))).thenAnswer((_) async => 1);

        //act
        await localDataSource.createTaskToCache(taskLocalModel);

        //assert
        verify(() => mockDatabase.insert('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()))).called(1);
        expect(null, isA<void>());
      });

      test('должен выбрасывать ошибку, если задача не была добавлена (ответ insert - 0)', ()async{
        //arrange
        when(()=>mockDatabase.insert(any(), any())).thenAnswer((_) async => 0);

        //act
        try{
          await localDataSource.createTaskToCache(taskLocalModel);
        } catch(e){
          //assert
          expect(e, isA<CacheException>());
        }
      });
    });

    group('и его метод deleteExactTaskFromCache', (){
      test('должен успешно удалять задачу', ()async{
        //assert
        when(()=>mockDatabase.delete('tasks', where: 'id = ?', whereArgs: [taskLocalModel.id])).thenAnswer((_) async=>1);

        //act
        await localDataSource.deleteExactTaskFromCache(taskLocalModel);

        //assert
        verify(() => mockDatabase.delete('tasks', where: 'id = ?', whereArgs: [taskLocalModel.id])).called(1);
        expect(null, isA<void>());
      });

      test('должен выбрасывать ошибку, если задача не была удалена', ()async{
        //assert
        when(() => mockDatabase.delete('tasks', where: 'id = ?', whereArgs: [taskLocalModel.id])).thenAnswer((_) async=>0);

        //act
        try{
          await localDataSource.deleteExactTaskFromCache(taskLocalModel);
        }catch(e){
          //assert
          expect(e, isA<CacheException>());
        }
      });
    });
    group('и его метод editTaskToCache', (){
      test('должен успешно редактировать задачу', ()async{
        //assert
        when(()=>mockDatabase.update('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()), where: 'id = ?', whereArgs: [taskLocalModel.id])).thenAnswer((_) async=>1);

        //act
        await localDataSource.editTaskToCache(taskLocalModel, taskLocalModel);

        //assert
        verify(() => mockDatabase.update('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()), where: 'id = ?', whereArgs: [taskLocalModel.id])).called(1);
        expect(null, isA<void>());  
      });

      test('должен выбрасывать ошибку, если не удалось обновить задачу', ()async{
        //arrange
        when(()=>mockDatabase.update('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()), where: 'id = ?', whereArgs: [taskLocalModel.id])).thenAnswer((_) async=>0);

        //act
        try{
          await localDataSource.editTaskToCache(taskLocalModel, taskLocalModel);
        }catch(e){
          //assert
          expect(e, isA<CacheException>());
        }
      });
    });
    group('и его метод getAllTasksFromCache', (){
      test('должен возвращать все задачи с текущей ревизией', ()async{
        final tasksFromDB = [
        {
          'id': '1',
          'text': 'Task 1',
          'importance': 'basic',
          'done': false,
          'last_updated_by': 'user1',
          'changed_at': DateTime.utc(2023, 01, 02).toIso8601String(),
          'created_at': DateTime.utc(2023, 01, 01).toIso8601String(),
          'color': null,
          'deadline': null,
        },
        {
          'id': '2',
          'text': 'Task 2',
          'importance': 'basic',
          'done': false,
          'last_updated_by': 'user2',
          'changed_at': DateTime.utc(2023, 01, 03).toIso8601String(),
          'created_at': DateTime.utc(2023, 01, 02).toIso8601String(),
          'color': null,
          'deadline': null,
        }
        ];

        final convertedTasks = tasksFromDB.map((taskMap) => TaskLocalModel.fromJson(DBMapConverter.convertTaskFromDB(taskMap))).toList();


        const int localRevision = 1;

        //arrange
        when(() => mockDatabase.query('tasks')).thenAnswer((_) async => tasksFromDB);
        when(() => localDataSource.getRevision(mockDatabase)).thenAnswer((_) async => localRevision);

        //act
        final result = await localDataSource.getAllTasksFromCache();

        //assert
        expect(result.listTasks, convertedTasks);
        expect(result.localRevision, localRevision);
      });
    });
  });
}
