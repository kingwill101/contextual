import 'package:shelf/shelf.dart';

abstract class LogWriter {
  void logRequest(
    Request request,
    Response response,
    DateTime startTime,
    Duration elapsedTime, {
    int? memory,
  });

  void logError(
    Request request,
    Object error,
    StackTrace stackTrace,
    DateTime startTime,
    Duration elapsedTime, {
    int? memory,
  });
}
