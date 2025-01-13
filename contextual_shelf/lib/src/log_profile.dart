import 'package:shelf/shelf.dart';

abstract class LogProfile {
  bool shouldLogRequest(Request request);
}
