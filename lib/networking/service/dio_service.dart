import 'package:dio/dio.dart';
import '../model/post_model.dart';

class DioService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  DioService() {
    // Add interceptors for logging or global error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Do something before request is sent
          print('Dio Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Do something with response data
          print('Dio Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Do something with response error
          print('Dio Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<Post>> getPosts() async {
    try {
      final response = await _dio.get('/posts');

      // Dio automatically decodes JSON
      final List<dynamic> data = response.data;
      return data.take(10).map((json) => Post.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection Timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive Timeout');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Bad Response: ${e.response?.statusCode}');
      } else {
        throw Exception('Something went wrong: ${e.message}');
      }
    }
  }

  Future<Post> createPost(String title, String body) async {
    try {
      final response = await _dio.post(
        '/posts',
        data: {'title': title, 'body': body, 'userId': 1},
      );
      return Post.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }
}
