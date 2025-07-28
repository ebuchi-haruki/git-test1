import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class Todo {
  final String text;
  final DateTime? dueDate;

  Todo({required this.text, this.dueDate});
}

enum SortMode { dueDate, alphabet }

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];
  final TextEditingController _textFieldController = TextEditingController();
  DateTime? _selectedDate;
  SortMode _sortMode = SortMode.dueDate;

  void _sortTodos() {
    if (_sortMode == SortMode.dueDate) {
      _todos.sort((a, b) {
        final aDate = a.dueDate ?? DateTime(9999);
        final bDate = b.dueDate ?? DateTime(9999);
        return aDate.compareTo(bDate);
      });
    } else {
      _todos.sort((a, b) => a.text.compareTo(b.text));
    }
  }

  void _addTodoItem(String title, DateTime? dueDate) {
    if (title.trim().isEmpty) return;

    setState(() {
      _todos.add(Todo(text: title.trim(), dueDate: dueDate));
      _sortTodos();
    });

    _textFieldController.clear();
    _selectedDate = null;
  }

  void _toggleSortMode() {
    setState(() {
      _sortMode = _sortMode == SortMode.dueDate ? SortMode.alphabet : SortMode.dueDate;
      _sortTodos();
    });
  }

  void _displayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('新しいタスクを追加'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _textFieldController,
                  decoration: const InputDecoration(hintText: 'タスク内容を入力'),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _selectedDate == null
                          ? '期限なし'
                          : '期限: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                          setStateDialog(() {});
                        }
                      },
                      child: const Text('期限を選ぶ'),
                    ),
                  ],
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('キャンセル'),
                onPressed: () {
                  _textFieldController.clear();
                  _selectedDate = null;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('追加'),
                onPressed: () {
                  if (_textFieldController.text.isNotEmpty) {
                    _addTodoItem(_textFieldController.text, _selectedDate);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildTodoList() {
    if (_todos.isEmpty) {
      return const Center(
        child: Text(
          'タスクがまだありません。追加してください。',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      );
    }

    return ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (BuildContext context, int index) {
        final todo = _todos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(todo.text),
            subtitle: todo.dueDate != null
                ? Text("期限: ${todo.dueDate!.toLocal().toString().split(' ')[0]}")
                : const Text("期限なし"),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todoリスト'),
      ),
      backgroundColor: Colors.yellow[100],
      body: Column(
        children: [
          Expanded(child: _buildTodoList()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton.icon(
              onPressed: _toggleSortMode,
              icon: Icon(
                _sortMode == SortMode.dueDate
                    ? Icons.calendar_today
                    : Icons.sort_by_alpha,
              ),
              label: Text(
                _sortMode == SortMode.dueDate
                    ? '期限順で表示中 → 名前順に切替'
                    : '名前順で表示中 → 期限順に切替',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayDialog(context),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        tooltip: 'タスクを追加',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

