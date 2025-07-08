class HttpError {
  final Map<String, dynamic> errors;
  HttpError(this.errors);
  factory HttpError.fromJson(Map<String, dynamic> json) {
    return HttpError(json['errors']);
  }
}