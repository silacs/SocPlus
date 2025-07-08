import 'package:socplus/models/http_error.dart';

class HttpResponse<T> {
  final bool success;
  final HttpError? error;
  final T? body;
  HttpResponse(this.success, {this.error, this.body});
}