import "dart:convert";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "package:socplus/models/http_error.dart";
import "package:socplus/models/login_request.dart";
import "package:socplus/models/login_response.dart";
import "package:socplus/models/http_response.dart";
import "package:socplus/models/refresh_request.dart";
import "package:socplus/models/request_interface.dart";
import "package:socplus/models/send_code_request.dart";
import "package:socplus/models/signup_request.dart";
import "package:socplus/models/user.dart";
import "package:socplus/models/verify_request.dart";
import "package:socplus/screens/welcome_screen.dart";

class AuthService {
  static Future<String?> get accessToken async {
    return (await SharedPreferences.getInstance()).getString('accessToken');
  }

  static Future<void> setAccessToken(String value) async {
    (await SharedPreferences.getInstance()).setString('accessToken', value);
  }

  static Future<String?> get refreshToken async {
    return (await SharedPreferences.getInstance()).getString('refreshToken');
  }

  static Future<void> setRefreshToken(String value) async {
    (await SharedPreferences.getInstance()).setString('refreshToken', value);
  }

  static Future<Map<String, dynamic>> get decodedAccessToken async {
    var token = await accessToken;
    String body = utf8.decode(
      base64Decode(base64Url.normalize((token?.split('.')[1])!)),
    );
    return json.decode(body);
  }

  static final String baseUrl = 'http://192.168.0.111:80/api/auth';
  static Future<void> logOut(BuildContext context) async {
    var sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.clear();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return WelcomeScreen();
    }), (route) => false,);
  }

  static Future<void> refreshIfExpired(BuildContext context) async {
    if ((await decodedAccessToken)['exp'] <=
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) {
      for (int i = 0; i < 3; i++) {
        if ((await refresh()).success) return;
      }
      if (context.mounted) await logOut(context);
    }
  }

  static Future<HttpResponse> refresh() async {
    var token = await refreshToken;
    if (token == null) return HttpResponse(false);
    var res = await postJson(
      '$baseUrl/refresh',
      RefreshRequest((await refreshToken)!),
      null,
    );
    if (res.statusCode == 200) {
      setAccessToken(json.decode(res.body)['accessToken']);
      return HttpResponse(true);
    } else {
      return HttpResponse(false);
    }
  }

  static Future<HttpResponse> signup(SignupRequest data) async {
    final response = await postJson('$baseUrl/signup', data, null);
    if (response.statusCode == 200) {
      return HttpResponse(true);
    }
    return HttpResponse(
      false,
      error: HttpError.fromJson(json.decode(response.body)),
    );
  }

  static Future<HttpResponse<LoginResponse>> login(LoginRequest data) async {
    final response = await postJson('$baseUrl/login', data, null);
    if (response.statusCode == 200) {
      return HttpResponse(
        true,
        body: LoginResponse.fromJson(json.decode(response.body)),
      );
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(response.body)),
      );
    }
  }

  static Future<HttpResponse> verify(VerifyRequest data) async {
    final response = await postJson('$baseUrl/verify', data, null);
    if (response.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(response.body)),
      );
    }
  }

  static Future<HttpResponse> sendCode(SendCodeRequest data) async {
    final response = await postJson('$baseUrl/send-code', data, null);
    if (response.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(response.body)),
      );
    }
  }
  static Future<HttpResponse<User>> getSelf() async {
    final response = await http.get(Uri.parse(baseUrl), headers: {
      'Authorization': 'Bearer ${await accessToken}'
    });
    if (response.statusCode == 200) {
      return HttpResponse(true, body: User.fromJson(json.decode(response.body)));
    }
    return HttpResponse(false, error: HttpError.fromJson(json.decode(response.body)));
  }
  static Future<HttpResponse> deleteUser() async  {
    final response = await http.delete(Uri.parse(baseUrl), headers: {
      'Authorization': 'Bearer ${await accessToken}'
    });
    if (response.statusCode == 200) {
      return HttpResponse(true);
    }
    return HttpResponse(false, error: HttpError.fromJson(json.decode(response.body)));
  }
  static Future<http.Response> postJson(
    String url,
    Request? body,
    Map<String, String>? headers,
  ) async {
    var oldHeaders = {'Content-Type': 'application/json'};
    if (headers != null) oldHeaders.addAll(headers);
    return await http.post(
      Uri.parse(url),
      body: jsonEncode(body?.toJson()),
      headers: oldHeaders,
    );
  }
}
