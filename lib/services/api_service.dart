import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:todo_app/models/todo_model.dart';

class ApiService {
  static final String _baseUrl = Platform.isIOS ? 'http://localhost:5001' : 'http://10.0.2.2:5001';
  Future<List<TodoModel>> getAllTodos() async {
    final response = await http.get(Uri.parse('$_baseUrl/todos'));
    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) => TodoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<TodoModel> getTodo(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/todos/$id'));
    if (response.statusCode == 200) {
      return TodoModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load todo $id');
    }
  }

  Future<TodoModel> createTodo(TodoModel todo) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/todos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(todo.toJson()),
    );
    if (response.statusCode == 201) {
      return TodoModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create todo');
    }
  }

  Future<TodoModel> updateTodo(TodoModel todo) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/todos/${todo.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(todo.toJson()),
    );
    if (response.statusCode == 200) {
      return TodoModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update todo');
    }
  }

  Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/todos/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo');
    }
  }
}
