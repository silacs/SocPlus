class LoginResponse {
  final String accessToken;
  final String refreshToken;
  const LoginResponse(this.accessToken, this.refreshToken);
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(json['accessToken'], json['refreshToken']);
  }
}