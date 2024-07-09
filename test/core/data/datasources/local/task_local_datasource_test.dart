import 'package:demetiapp/core/data/datasources/local/database_helper.dart';
import 'package:demetiapp/core/data/datasources/local/database_mapper.dart';
import 'package:demetiapp/core/data/datasources/local/task_local_datasource.dart';
import 'package:demetiapp/core/data/dto/task_local_dto.dart';
import 'package:demetiapp/core/error/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';

class FallbackTaskLocalModel extends Fake implements TaskLocalModel{}

class DataBaseHelperMock extends Mock implements DatabaseHelper{}
class TaskLocalDatasourseMock extends Mock implements TaskLocalDatasourceImpl{}
class DatabaseMock extends Mock implements Database{}

void main(){
  late DataBaseHelperMock dbHelperMock;
  late TaskLocalDatasourceImpl db;
  late TaskLocalDatasourseMock dbMock;
  late DatabaseMock sqfliteMock;

  setUpAll(() {
    dbHelperMock = DataBaseHelperMock();
    sqfliteMock = DatabaseMock();
    dbMock = TaskLocalDatasourseMock();
    db = TaskLocalDatasourceImpl(databaseHelper: dbHelperMock);


    when(()=>dbHelperMock.database).thenAnswer((_) async => sqfliteMock);
  },);

  group('TaskLocalDatasource', (){
    final taskLocalModel = TaskLocalModel(id: '1', text: 'text', importance: 'basic', done: false, lastUpdatedBy: 'test', changedAt: DateTime.utc(2023, 01, 02), createdAt: DateTime.utc(2023, 01, 01));
    final localResult = TaskLocalModelWithRevision(listTasks: [taskLocalModel], localRevision: 1);
    final List<Map<String, dynamic>> dbResult = [taskLocalModel.toJson()];
    group('и его метод ceateTaskToCache', (){
      test('должен успешно добавлять новую задачу', ()async{
        //arrange
        when(()=>sqfliteMock.insert('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()))).thenAnswer((_) async => 1);

        //act
        await db.createTaskToCache(taskLocalModel);

        //assert
        verify(() => sqfliteMock.insert('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()))).called(1);
        expect(null, isA<void>());
      });

      test('должен выбрасывать ошибку, если задача не была добавлена (ответ insert - 0)', ()async{
        //arrange
        when(()=>sqfliteMock.insert(any(), any())).thenAnswer((_) async => 0);

        //act
        try{
          await db.createTaskToCache(taskLocalModel);
        } catch(e){
          //assert
          expect(e, isA<CacheException>());
        }
      });
    });

    group('и его метод deleteExactTaskFromCache', (){
      test('должен успешно удалять задачу', ()async{
        //assert
        when(()=>sqfliteMock.delete('tasks', where: 'id = ?', whereArgs: [taskLocalModel.id])).thenAnswer((_) async=>1);

        //act
        await db.deleteExactTaskFromCache(taskLocalModel);

        //assert
        verify(() => sqfliteMock.delete('tasks', where: 'id = ?', whereArgs: [taskLocalModel.id])).called(1);
        expect(null, isA<void>());
      });

      test('должен выбрасывать ошибку, если задача не была удалена', ()async{
        //assert
        when(() => sqfliteMock.delete('tasks', where: 'id = ?', whereArgs: [taskLocalModel.id])).thenAnswer((_) async=>0);

        //act
        try{
          await db.deleteExactTaskFromCache(taskLocalModel);
        }catch(e){
          //assert
          expect(e, isA<CacheException>());
        }
      });
    });
    group('и его метод editTaskToCache', (){
      test('должен успешно редактировать задачу', ()async{
        //assert
        when(()=>sqfliteMock.update('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()), where: 'id = ?', whereArgs: [taskLocalModel.id])).thenAnswer((_) async=>1);

        //act
        await db.editTaskToCache(taskLocalModel, taskLocalModel);

        //assert
        verify(() => sqfliteMock.update('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()), where: 'id = ?', whereArgs: [taskLocalModel.id])).called(1);
        expect(null, isA<void>());  
      });

      test('должен выбрасывать ошибку, если не удалось обновить задачу', ()async{
        //arrange
        when(()=>sqfliteMock.update('tasks', DBMapConverter.convertTaskForDB(taskLocalModel.toJson()), where: 'id = ?', whereArgs: [taskLocalModel.id])).thenAnswer((_) async=>0);

        //act
        try{
          await db.editTaskToCache(taskLocalModel, taskLocalModel);
        }catch(e){
          //assert
          expect(e, isA<CacheException>());
        }
      });
    });
  });
}
