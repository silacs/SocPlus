import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:socplus/models/comment.dart';
import 'package:socplus/models/comment_request.dart';
import 'package:socplus/models/follow_request.dart';
import 'package:socplus/models/http_error.dart';
import 'package:socplus/models/http_response.dart';
import 'package:socplus/models/paginated.dart';
import 'package:socplus/models/post.dart';
import 'package:socplus/models/request_interface.dart';
import 'package:socplus/models/user.dart';
import 'package:socplus/models/vote_request.dart';
import 'package:socplus/models/votes.dart';
import 'package:socplus/services/auth_service.dart';

class PostService {
  static final String baseUrl = 'http://silacs.ddns.net/api/post';
  static Future<Map<String, String>> get authorizationHeader async {
    return {'Authorization': 'Bearer ${await AuthService.accessToken}'};
  }

  static Map<String, String> paginationParams(int page, int pageSize) {
    return {'page': page.toString(), 'pageSize': pageSize.toString()};
  }

  static Future<HttpResponse> follow(String userId) async {
    var res = await postJson(
      '$baseUrl/add-follow',
      FollowRequest(userId: userId),
      null,
    );
    if (res.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(false);
    }
  }

  //Get
  static Future<HttpResponse<Paginated<Post>>> search({
    String keywords = '',
    int page = 1,
    int pageSize = 10,
    BuildContext? context,
  }) async {
    try {
      var res = await http.get(
      Uri.parse('$baseUrl/search').replace(
        queryParameters: {
          'keywords': keywords,
          ...paginationParams(page, pageSize),
        },
      ),
      headers: await authorizationHeader
    );
    if (res.statusCode == 200) {
      return HttpResponse(
        true,
        body: Paginated<Post>.fromJson(json.decode(res.body), Post.fromJson),
      );
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(res.body)),
      );
    }
    } on SocketException catch (_) {
      return HttpResponse(false);
    }
  }

  static Future<HttpResponse> isFollowing(String userId) async {
    var res = await http.get(
      Uri.parse('$baseUrl/following/$userId'),
      headers: await authorizationHeader,
    );
    if (res.statusCode == 200) {
      return HttpResponse(true, body: json.decode(res.body) as bool);
    } else {
      return HttpResponse(false);
    }
  }

  static Future<HttpResponse> isFriend(String userId) async {
    var res = await http.get(
      Uri.parse('$baseUrl/friends/$userId'),
      headers: await authorizationHeader,
    );
    if (res.statusCode == 200) {
      return HttpResponse(true, body: json.decode(res.body) as bool);
    } else {
      return HttpResponse(false);
    }
  }

  static Future<HttpResponse<Paginated<User>>> getFollowings({
    int page = 1,
    int pageSize = 10,
  }) async {
    var res = await http.get(
      Uri.parse(
        '$baseUrl/followings',
      ).replace(queryParameters: paginationParams(page, pageSize)),
      headers: await authorizationHeader,
    );
    var body = json.decode(res.body);
    if (res.statusCode == 200) {
      return HttpResponse(true, body: Paginated.fromJson(body, User.fromJson));
    } else {
      return HttpResponse(false, error: HttpError.fromJson(body));
    }
  }

  static Future<HttpResponse<Paginated<User>>> getFollowers({
    int page = 1,
    int pageSize = 10,
  }) async {
    var res = await http.get(
      Uri.parse(
        '$baseUrl/followers',
      ).replace(queryParameters: paginationParams(page, pageSize)),
      headers: await authorizationHeader,
    );
    var body = json.decode(res.body);
    if (res.statusCode == 200) {
      return HttpResponse(true, body: Paginated.fromJson(body, User.fromJson));
    } else {
      return HttpResponse(false, error: HttpError.fromJson(body));
    }
  }

  static Future<HttpResponse<Votes>> getVotes(String postId) async {
    var res = await http.get(
      Uri.parse('$baseUrl/$postId/votes'),
      headers: await authorizationHeader,
    );
    if (res.statusCode == 200) {
      return HttpResponse(true, body: Votes.fromJson(json.decode(res.body)));
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(res.body)),
      );
    }
  }

  static Future<HttpResponse<Paginated<Comment>>> getReplies(
    String commentId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    var res = await http.get(
      Uri.parse(
        '$baseUrl/comment/$commentId/replies',
      ).replace(queryParameters: paginationParams(page, pageSize)),
      headers: await authorizationHeader,
    );
    if (res.statusCode == 200) {
      var result = Paginated<Comment>.fromJson(
        json.decode(res.body),
        Comment.fromJson,
      );
      return HttpResponse(true, body: result);
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(res.body)),
      );
    }
  }

  static Future<HttpResponse<Paginated<Comment>>> getComments(
    String postId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    var res = await http.get(
      Uri.parse('$baseUrl/$postId/comments').replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      ),
      headers: await authorizationHeader,
    );
    if (res.statusCode == 200) {
      var result = Paginated<Comment>.fromJson(
        json.decode(res.body),
        Comment.fromJson,
      );
      return HttpResponse(true, body: result);
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(res.body)),
      );
    }
  }

  static Future<HttpResponse<Paginated<Post>>> getOwnPosts({
    BuildContext? context,
    int page = 1,
    int pageSize = 10,
    String keywords = '',
  }) async {
    try {
          var res = await http.get(Uri.parse('$baseUrl/me').replace(queryParameters: paginationParams(page, pageSize)), headers: await authorizationHeader);
    if (res.statusCode == 200) {
      return HttpResponse(true, body: Paginated<Post>.fromJson(json.decode(res.body), Post.fromJson));
    } else {
      return HttpResponse(false);
    }
    } on SocketException catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Network Error")));
      }
      return HttpResponse(false);
    }
  }
  static Future<HttpResponse<Paginated<Post>>> getPosts({
    BuildContext? context,
    int page = 1,
    int pageSize = 10,
    String keywords = '',
  }) async {
    try {
      var response = await http.get(
        Uri.parse(baseUrl).replace(
          queryParameters: {
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        ),
        headers: await authorizationHeader,
      );
      if (response.statusCode == 200) {
        var result = Paginated<Post>.fromJson(
          json.decode(response.body),
          Post.fromJson,
        );
        return HttpResponse(true, body: result);
      } else {
        return HttpResponse(
          false,
          error: HttpError.fromJson(json.decode(response.body)),
        );
      }
    } on SocketException catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Network Error")));
      }
      return HttpResponse(false);
    }
  }

  //Post
  static Future<HttpResponse> addVote(VoteRequest data) async {
    var res = await postJson('$baseUrl/add-vote', data, null);
    if (res.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(res.body)),
      );
    }
  }

  static Future<HttpResponse> addComment(CommentRequest data) async {
    var res = await postJson('$baseUrl/add-comment', data, null);
    if (res.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(res.body)),
      );
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

  //Delete
  static Future<HttpResponse> deleteComment(String commentId) async {
    var accessToken = await AuthService.accessToken;
    var res = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (res.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(res.body)),
      );
    }
  }

  static Future<HttpResponse> deletePost(String postId) async {
    var accessToken = await AuthService.accessToken;
    var res = await http.delete(
      Uri.parse('$baseUrl/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (res.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(
        false,
        error: HttpError.fromJson(json.decode(res.body)),
      );
    }
  }

  static Future<HttpResponse> removeFollow(String userId) async {
    var res = await http.delete(
      Uri.parse('$baseUrl/followings/$userId'),
      headers: await authorizationHeader,
    );
    if (res.statusCode == 200) {
      return HttpResponse(true);
    } else {
      return HttpResponse(false);
    }
  }

  //Helpers
  static Future<http.Response> postJson(
    String url,
    Request? body,
    Map<String, String>? headers,
  ) async {
    var oldHeaders = {
      'Content-Type': 'application/json',
      ...await authorizationHeader,
    };
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
