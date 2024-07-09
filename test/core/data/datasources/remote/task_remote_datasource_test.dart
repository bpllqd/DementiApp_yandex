import 'package:demetiapp/core/data/datasources/remote/task_remote_datasource.dart';
import 'package:demetiapp/core/data/dto/task_api_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class DioMock extends Mock implements Dio{}
class ResponseMock extends Mock implements Response{}

void main(){
  late TaskRemoteDataSourceImpl api;
  late DioMock dioMock;
  late ResponseMock responseMock;

  setUpAll((){
    dioMock = DioMock();
    responseMock = ResponseMock();
    api = TaskRemoteDataSourceImpl(dio: dioMock);
  });

  group('RemoteDatasourse', (){
    final task = TaskApiModel(id: '1', text: 'text', color: null, done: false, importance: 'basic', createdAt: DateTime.utc(2023, 01, 01), changedAt: DateTime.utc(2023, 01, 02), lastUpdatedBy: 'test');
    const int revision = 1;
    final Map<String, dynamic> jsonResponse = {
      'revision': 2,
      'element': {'id': '1', 'text': 'text', 'color' : 'color', 'importance':'basic', 'done': 'false', 'created_at':'2023-01-01', 'changed_at':'2023-01-02', 'last_updated_by':'test'},
    };
    group('и его метод createTask', (){
      test('при успешном запроме должен возвращать TaskApiModelWithRevision', ()async{
        // Arrange
        when(()=>responseMock.statusCode).thenReturn(200);
        when(()=>responseMock.data).thenReturn(jsonResponse);
        when(() => dioMock.post(
          any(),
          options: any(named: 'options'),
          data: any(named: 'data'),
        )).thenAnswer((_) async => responseMock);

        // Act
        final result = await api.createTask(task, revision);

        // Assert
        expect(result.apiRevision, 2);
        expect(result.listTasks.length, 1);
        expect(result.listTasks[0].id, 1);
        expect(result.listTasks[0].text, 'test');
      });
    });
  });

}
