import 'package:flutter/material.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/services/api_service.dart';

class TodoDetailScreen extends StatefulWidget {
  final TodoModel? todo;

  const TodoDetailScreen({super.key, this.todo});

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
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            CheckboxListTile(
              title: const Text('Completed'),
              value: _completed,
              onChanged: (value) {
                setState(() {
                  _completed = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
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
              child: const Text('Save'),
            ),
            const SizedBox(height: 8),
            if (widget.todo != null)
              ElevatedButton(
                onPressed: () async {
                  await _apiService.deleteTodo(widget.todo!.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
          ],
        ),
      ),
    );
  }
}
