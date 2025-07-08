import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:socplus/models/comment.dart';
import 'package:socplus/models/comment_request.dart';
import 'package:socplus/models/http_error.dart';
import 'package:socplus/models/http_response.dart';
import 'package:socplus/models/post.dart';
import 'package:socplus/models/request_interface.dart';
import 'package:socplus/models/vote_request.dart';
import 'package:socplus/models/votes.dart';
import 'package:socplus/services/auth_service.dart';

class PostService {
  static final String baseUrl = 'https://192.168.0.111/api/post';

  static Future<HttpResponse<Votes>> getVotes(String postId) async {
    var token = await AuthService.accessToken;
    var res = await http.get(Uri.parse('$baseUrl/$postId/votes'), headers: {
      'Authorization': 'Bearer $token'
    });
    if (res.statusCode == 200) {
      return HttpResponse(true, body: Votes.fromJson(json.decode(res.body)));
    } else {
      return HttpResponse(false, error: HttpError.fromJson(json.decode(res.body)));
    }
  }

  static Future<HttpResponse<List<Comment>>> getComments(String postId) async {
    var res = await http.get(Uri.parse('$baseUrl/$postId/comments'));
    if (res.statusCode == 200) {
      List<dynamic> body = json.decode(res.body);
      List<Comment> comments = body.map((c) => Comment.fromJson(c as Map<String, dynamic>)).toList();
      return HttpResponse(true, body: comments);
    } else {
      return HttpResponse(false, error: HttpError.fromJson(json.decode(res.body)));
    }
  }

  static Future<HttpResponse> addComment(CommentRequest data) async {
     var res = await postJson('$baseUrl/add-comment', data, null);
    if (res.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(false, error: HttpError.fromJson(json.decode(res.body)));
    }
  }

  static Future<HttpResponse> addVote(VoteRequest data) async {
    var res = await postJson('$baseUrl/add-vote', data, null);
    if (res.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(false, error: HttpError.fromJson(json.decode(res.body)));
    }
  }
  static Future<HttpResponse> deletePost(String postId) async {
    var accessToken = await AuthService.accessToken;
    var res = await http.delete(Uri.parse('$baseUrl/$postId'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    });
    if (res.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(false, error: HttpError.fromJson(json.decode(res.body)));
    }
  }
  static Future<HttpResponse> uploadPost(
    String text,
    int visibility,
    List<File> imageFiles,
  ) async {
    var accessToken = await AuthService.accessToken;
    var uri = Uri.parse('$baseUrl/upload');

    var request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = "Bearer $accessToken"
          ..fields['Text'] = text
          ..fields['Visibility'] = visibility.toString();

    for (var file in imageFiles) {
      var stream = http.ByteStream(file.openRead());
      var length = await file.length();

      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      var multipartFile = http.MultipartFile(
        'Images',
        stream,
        length,
        filename: file.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      return HttpResponse(true);
    } else {
      var body = json.decode(await response.stream.bytesToString());
      return HttpResponse(false, error: HttpError.fromJson(body));
    }
  }

  static Future<HttpResponse<List<Post>>> getPosts() async {
    var response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Post> posts = [];
      for (var post in body) {
        posts.add(Post.fromJson(post));
      }
      return HttpResponse(true, body: posts);
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(response.body)),
      );
    }
  }
  // static Future<Image> getImage(String fileName) async {
  //   var accessToken = await AuthService.accessToken;
  //   var res = await http.get(url)
  // }

  static Future<http.Response> postJson(
    String url,
    Request? body,
    Map<String, String>? headers,
  ) async {
    var accessToken = await AuthService.accessToken;
    var oldHeaders = {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'};
    if (headers != null) oldHeaders.addAll(headers);
    return await http.post(
      Uri.parse(url),
      body: jsonEncode(body?.toJson()),
      headers: oldHeaders,
    );
  }

  static Future<List<File>> pickImages() async {
    final imagePicker = ImagePicker();
    final List<XFile> images = await imagePicker.pickMultiImage();
    return images.map((xfile) => File(xfile.path)).toList();
  }
}
