import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/post_model.dart';
import '../../hive/todo_model.dart'; // Just for error type demonstrating
import 'dart:io';

class HttpService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        // Take only first 10 for demo
        return jsonData.take(10).map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet Connection');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Post> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'body': body,
        'userId': 1,
      }),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }
}
