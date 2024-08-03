import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  String description;
  DateTime dueDate;

  Task({required this.title, required this.description, required this.dueDate});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Task> tasks = [];

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void updateTask(int index, Task task) {
    setState(() {
      tasks[index] = task;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Dismissible(
            key: Key(task.hashCode.toString()),
            onDismissed: (direction) {
              deleteTask(index);
            },
            background: Container(color: Colors.red),
            child: ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
              trailing: Text(DateFormat('yyyy-MM-dd').format(task.dueDate)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => TaskDialog(
                    task: task,
                    onTaskAdded: addTask,
                    onTaskUpdated: updateTask,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => TaskDialog(
              onTaskAdded: addTask,
              onTaskUpdated: updateTask,
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onTaskAdded;
  final Function(int, Task) onTaskUpdated;

  TaskDialog({this.task, required this.onTaskAdded, required this.onTaskUpdated});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  get tasks => null;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController = TextEditingController(text: widget.task!.title);
      _descriptionController = TextEditingController(text: widget.task!.description);
      _selectedDate = widget.task!.dueDate;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task != null ? 'Edit Task' : 'Add Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          ListTile(
            title: Text('Due Date'),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2021),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null && pickedDate != _selectedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _titleController.text;
            final description = _descriptionController.text;
            final dueDate = _selectedDate;

            if (title.isNotEmpty && description.isNotEmpty) {
              final newTask = Task(
                title: title,
                description: description,
                dueDate: dueDate,
              );
              if (widget.task != null) {
                widget.onTaskUpdated(tasks.indexOf(widget.task!), newTask);
              } else {
                widget.onTaskAdded(newTask);
              }
              Navigator.of(context).pop();
            } else {
              // Show error message
            }
          },
          child: Text(widget.task != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
