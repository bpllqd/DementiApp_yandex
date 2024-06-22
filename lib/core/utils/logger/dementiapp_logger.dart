import 'package:logger/logger.dart';

class DementiappLogger {

  static final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      lineLength: 50,
      errorMethodCount: 3,
      colors: true,
      printEmojis: true,
    ),
  );

  static void log(
    dynamic message, [
    Level level = Level.trace,
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    logger.log(level, message, error: error, stackTrace: stackTrace);
  }

  static void traceLog(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    logger.t(message, error: error, stackTrace: stackTrace);
  }

  static void debugLog(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void infoLog(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warningLog(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void errorLog(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fLog(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    logger.f(message, error: error, stackTrace: stackTrace);
  }
}
