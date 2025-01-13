import 'package:contextual_shelf/src/log_profile.dart';
import 'package:shelf/shelf.dart';

class LogNonGetRequests implements LogProfile {
  @override
  bool shouldLogRequest(Request request) {
    final method = request.method.toLowerCase();
    return ['post', 'put', 'patch', 'delete'].contains(method);
  }
}
