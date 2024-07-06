import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio provideDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://beta.mrdekk.ru/todo',
        headers: {'Authorization': 'Bearer Gilthoniel'},
      ),
    );
  }
}
