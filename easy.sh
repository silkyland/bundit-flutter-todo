#!/bin/bash

# Create the directory structure
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/screens

# Create the Data Model file
cat <<EOL > lib/models/todo_model.dart
class TodoModel {
  final int id;
  final String title;
  final bool completed;

  TodoModel({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
    };
  }
}
EOL

# Create the API Service file
cat <<EOL > lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:your_app/models/todo_model.dart';

class ApiService {
  static const String _baseUrl = 'https://your-api-url.com'; // เปลี่ยนเป็น base URL ของ API ที่ใช้

  Future<List<TodoModel>> getAllTodos() async {
    final response = await http.get(Uri.parse('\$_baseUrl/todos'));
    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) => TodoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  Future<TodoModel> getTodo(int id) async {
    final response = await http.get(Uri.parse('\$_baseUrl/todos/\$id'));
    if (response.statusCode == 200) {
      return TodoModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load todo \$id');
    }
  }

  Future<TodoModel> createTodo(TodoModel todo) async {
    final response = await http.post(
      Uri.parse('\$_baseUrl/todos'),
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
      Uri.parse('\$_baseUrl/todos/\${todo.id}'),
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
    final response = await http.delete(Uri.parse('\$_baseUrl/todos/\$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo');
    }
  }
}
EOL

# Create the Todo List Screen file
cat <<EOL > lib/screens/todo_list_screen.dart
import 'package:flutter/material.dart';
import 'package:your_app/models/todo_model.dart';
import 'package:your_app/services/api_service.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<TodoModel>> _todosFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _todosFuture = _apiService.getAllTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: FutureBuilder<List<TodoModel>>(
        future: _todosFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final todos = snapshot.data!;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  trailing: Checkbox(
                    value: todo.completed,
                    onChanged: null,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoDetailScreen(todo: todo),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('\${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailScreen(todo: null),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
EOL

# Create the Todo Detail Screen file
cat <<EOL > lib/screens/todo_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:your_app/models/todo_model.dart';
import 'package:your_app/services/api_service.dart';

class TodoDetailScreen extends StatefulWidget {
  final TodoModel? todo;

  TodoDetailScreen({this.todo});

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final ApiService _apiService = ApiService();
  final _titleController = TextEditingController();
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _completed = widget.todo!.completed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'New Todo' : 'Edit Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            CheckboxListTile(
              title: Text('Completed'),
              value: _completed,
              onChanged: (value) {
                setState(() {
                  _completed = value ?? false;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final todo = TodoModel(
                  id: widget.todo?.id ?? 0,
                  title: _titleController.text,
                  completed: _completed,
                );
                if (widget.todo == null) {
                  await _apiService.createTodo(todo);
                } else {
                  await _apiService.updateTodo(todo);
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            SizedBox(height: 8),
            if (widget.todo != null)
              ElevatedButton(
                onPressed: () async {
                  await _apiService.deleteTodo(widget.todo!.id);
                  Navigator.pop(context);
                },
                child: Text('Delete'),
                style: ElevatedButton.styleFrom(primary: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
EOL

# Create the main.dart file
cat <<EOL > lib/main.dart
import 'package:flutter/material.dart';
import 'package:your_app/screens/todo_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      home: TodoListScreen(),
    );
  }
}
EOL

echo "Files and directories created successfully!"
