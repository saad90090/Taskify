import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_model.dart'; // Your Task class file

class AddTaskScreen extends StatefulWidget {
  final List<Task> existingTasks;
  const AddTaskScreen({Key? key, required this.existingTasks})
      : super(key: key);
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _priority = 'Medium';
  final List<String> _priorityOptions = ['High', 'Medium', 'Low'];

  String _mainStatus = 'To Do';
  final List<String> _mainStatusOptions = ['To Do', 'In Review', 'Completed'];

  String? _progressStatus;
  final List<String> _progressStatusOptions = [
    'On Track',
    'Meeting',
    'At Risk'
  ];

  DateTime _dueDate = DateTime.now().add(Duration(days: 1));

  int _linkedTasks = 0;
  int _comments = 0;
  List<String> _assignedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                decoration: InputDecoration(labelText: 'Task Title'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Enter task title'
                    : null,
                onSaved: (value) => _title = value!.trim(),
              ),
              SizedBox(height: 12),

              // Priority
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Priority'),
                value: _priority,
                items: _priorityOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) => setState(() => _priority = val!),
              ),
              SizedBox(height: 12),

              // Main Status
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Main Status'),
                value: _mainStatus,
                items: _mainStatusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _mainStatus = val!),
              ),
              SizedBox(height: 12),

              // Progress Status (optional)
              DropdownButtonFormField<String?>(
                decoration:
                    InputDecoration(labelText: 'Progress Status (optional)'),
                value: _progressStatus,
                items: [null, ..._progressStatusOptions]
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s ?? 'None'),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _progressStatus = val),
              ),
              SizedBox(height: 12),

              // Due Date Picker
              ListTile(
                title: Text('Due Date: ${DateFormat.yMMMd().format(_dueDate)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now().subtract(Duration(days: 1)),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dueDate = pickedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 12),

              // Linked Tasks
              TextFormField(
                decoration: InputDecoration(labelText: 'Linked Tasks'),
                keyboardType: TextInputType.number,
                initialValue: '0',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  return int.tryParse(value) == null
                      ? 'Enter valid number'
                      : null;
                },
                onSaved: (value) =>
                    _linkedTasks = int.tryParse(value ?? '0') ?? 0,
              ),
              SizedBox(height: 12),

              // Comments
              TextFormField(
                decoration: InputDecoration(labelText: 'Comments'),
                keyboardType: TextInputType.number,
                initialValue: '0',
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  return int.tryParse(value) == null
                      ? 'Enter valid number'
                      : null;
                },
                onSaved: (value) => _comments = int.tryParse(value ?? '0') ?? 0,
              ),
              SizedBox(height: 12),

              // Assigned Users
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Assigned Users (comma separated)'),
                onSaved: (value) {
                  _assignedUsers = (value ?? '')
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                },
              ),
              SizedBox(height: 24),

              // Add Task Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final newTask = Task(
                      title: _title,
                      priority: _priority,
                      status: _mainStatus,
                      progressStatus: _progressStatus,
                      dueDate: _dueDate,
                      linkedTasks: _linkedTasks,
                      comments: _comments,
                      assignedUsers: _assignedUsers,
                    );

                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('You must be logged in to add a task')),
                        );
                        return;
                      }

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('tasks')
                          .add({
                        'title': _title,
                        'priority': _priority,
                        'status': _mainStatus,
                        'progressStatus': _progressStatus,
                        'dueDate': Timestamp.fromDate(_dueDate),
                        'linkedTasks': _linkedTasks,
                        'comments': _comments,
                        'assignedUsers': _assignedUsers,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      Navigator.pop(context, newTask);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add task: $e')),
                      );
                    }
                  }
                },
                child: Text('Add Task'),
              ),

              SizedBox(height: 12),

              // Test Firestore Write Button
              ElevatedButton(
                onPressed: () async {
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'You must be logged in to test Firestore')),
                      );
                      return;
                    }

                    final tasksRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('tasks');

                    await tasksRef.add({
                      'title': 'Test Task',
                      'priority': 'Low',
                      'status': 'To Do',
                      'progressStatus': null,
                      'dueDate': Timestamp.fromDate(
                          DateTime.now().add(Duration(days: 7))),
                      'linkedTasks': 0,
                      'comments': 0,
                      'assignedUsers': [],
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Test task added successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add test task: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                child: Text('Test Firestore Write'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
