import 'dart:io';

import 'package:contextual_shelf/src/log_profile.dart';
import 'package:contextual_shelf/src/log_writer.dart';
import 'package:shelf/shelf.dart';

class HttpLogger {
  final LogProfile logProfile;
  final LogWriter logWriter;

  HttpLogger(this.logProfile, this.logWriter);

  Middleware get middleware {
    return (innerHandler) {
      return (request) async {
        var startTime = DateTime.now();
        var watch = Stopwatch()..start();

        Response response;
        try {
          response = await innerHandler(request);
          watch.stop();
        } catch (error, stackTrace) {
          watch.stop();
          final memoryUsage = (ProcessInfo.currentRss / (1024 * 1024))
              .round(); // Memory usage in MB

          if (logProfile.shouldLogRequest(request)) {
            logWriter.logError(
              request,
              error,
              stackTrace,
              startTime,
              watch.elapsed,
              memory: memoryUsage,
            );
          }
          rethrow;
        }

        final memoryUsage = (ProcessInfo.currentRss / (1024 * 1024))
            .round(); // Memory usage in MB

        if (logProfile.shouldLogRequest(request)) {
          logWriter.logRequest(
            request,
            response,
            startTime,
            watch.elapsed,
            memory: memoryUsage,
          );
        }

        return response;
      };
    };
  }
}
