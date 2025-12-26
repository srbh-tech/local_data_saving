import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'todo_model.dart';
import '../widgets/custom_card.dart';

class HivePage extends StatefulWidget {
  const HivePage({super.key});

  @override
  State<HivePage> createState() => _HivePageState();
}

class _HivePageState extends State<HivePage> {
  final TextEditingController _todoController = TextEditingController();
  late Box<TodoModel> _todoBox;

  @override
  void initState() {
    super.initState();
    _todoBox = Hive.box<TodoModel>('todos');
  }

  void _addTodo() {
    if (_todoController.text.isNotEmpty) {
      final newTodo = TodoModel(title: _todoController.text);
      _todoBox.add(newTodo);
      _todoController.clear();
    }
  }

  void _deleteTodo(int index) {
    _todoBox.deleteAt(index);
  }

  void _toggleTodo(TodoModel todo) {
    todo.isDone = !todo.isDone;
    todo.save();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hive Demo', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'A fast NoSQL database. Great for storing objects and lists.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoController,
                  decoration: InputDecoration(
                    hintText: 'Add a new task...',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: _addTodo,
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _todoBox.listenable(),
              builder: (context, Box<TodoModel> box, _) {
                if (box.values.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks yet!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final todo = box.getAt(index);
                    if (todo == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomCard(
                        child: Row(
                          children: [
                            Checkbox(
                              value: todo.isDone,
                              onChanged: (val) => _toggleTodo(todo),
                            ),
                            Expanded(
                              child: Text(
                                todo.title,
                                style: TextStyle(
                                  decoration: todo.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: todo.isDone ? Colors.grey : null,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteTodo(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
