import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Assume you have these files/classes in your project
import 'add_task_screen.dart';
import 'app_drawer.dart';

class Task {
  final String? id;
  final String title;
  final String priority;
  final String status;
  final DateTime dueDate;
  final List<String>? assignedUsers;

  Task({
    this.id,
    required this.title,
    required this.priority,
    required this.status,
    required this.dueDate,
    this.assignedUsers,
  });

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      title: data['title'] ?? '',
      priority: data['priority'] ?? 'Low',
      status: data['status'] ?? 'To Do',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      assignedUsers: List<String>.from(data['assignedUsers'] ?? []),
    );
  }

  Task copyWith({String? id}) {
    return Task(
      id: id ?? this.id,
      title: this.title,
      priority: this.priority,
      status: this.status,
      dueDate: this.dueDate,
      assignedUsers: this.assignedUsers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'priority': priority,
      'status': status,
      'dueDate': Timestamp.fromDate(dueDate),
      'assignedUsers': assignedUsers,
    };
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  bool isLoading = true;
  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndLoadTasks();
  }

  Future<void> _initializeFirebaseAndLoadTasks() async {
    await Firebase.initializeApp();
    await _loadTasks();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in');
      return;
    }
    print('Loading tasks for user: ${user.email}');

    final tasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .collection('tasks');

    final snapshot = await tasksRef.get();
    print('Got ${snapshot.docs.length} task documents');

    setState(() {
      tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Doc ${doc.id}: $data');
        return Task.fromMap(data).copyWith(id: doc.id);
      }).toList();
    });
  }

  Future<void> _saveTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final tasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.email)
        .collection('tasks');

    final batch = FirebaseFirestore.instance.batch();

    for (var task in tasks) {
      final docRef = task.id != null ? tasksRef.doc(task.id) : tasksRef.doc();
      batch.set(docRef, task.toJson());
    }

    await batch.commit();
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'On Track':
        return Colors.purple;
      case 'Meeting':
        return Colors.blueAccent;
      case 'At Risk':
        return Colors.black87;
      case 'In Review':
        return Colors.pinkAccent;
      case 'Completed':
        return Colors.green;
      case 'To Do':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.darken(0.3),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    int count,
    String filter,
    Color textColor,
    Color bgColor,
  ) {
    final bool isSelected = selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = filter),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? bgColor.withOpacity(0.2) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? bgColor : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: bgColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? bgColor.darken(0.4) : textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                radius: 12,
                backgroundColor: isSelected ? bgColor : Colors.white,
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Task> filteredTasks = tasks.where((task) {
      final matchesFilter =
          selectedFilter == 'All' || task.status == selectedFilter;
      final matchesSearch = task.title.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchesFilter && matchesSearch;
    }).toList();

    int completedCount = tasks
        .where((task) => task.status == 'Completed')
        .length;
    int toDoCount = tasks.where((task) => task.status == 'To Do').length;
    int inReviewCount = tasks
        .where((task) => task.status == 'In Review')
        .length;

    return Scaffold(
      drawer: AppDrawer(currentScreen: "Tasks"),
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          'Task List',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black87),
            onPressed: () {
              final titles = tasks.map((e) => e.title).toList();
              //ShareHelper.shareTaskSummary(titles);
            },
            tooltip: "Share Tasks",
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              setState(() {
                if (value == 'Sort by Date') {
                  tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
                } else if (value == 'Sort by Priority') {
                  final priorityValue = (String priority) {
                    switch (priority) {
                      case 'High':
                        return 0;
                      case 'Medium':
                        return 1;
                      case 'Low':
                        return 2;
                      default:
                        return 3;
                    }
                  };
                  tasks.sort(
                    (a, b) => priorityValue(
                      a.priority,
                    ).compareTo(priorityValue(b.priority)),
                  );
                }
              });
              _saveTasks();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Sort by Date', child: Text('Sort by Date')),
              PopupMenuItem(
                value: 'Sort by Priority',
                child: Text('Sort by Priority'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    "All",
                    tasks.length,
                    'All',
                    Colors.black87,
                    Colors.purple,
                  ),
                  _buildFilterChip(
                    "Completed",
                    completedCount,
                    'Completed',
                    Colors.green.shade700,
                    Colors.green,
                  ),
                  _buildFilterChip(
                    "To Do",
                    toDoCount,
                    'To Do',
                    Colors.orange.shade700,
                    Colors.orange,
                  ),
                  _buildFilterChip(
                    "In Review",
                    inReviewCount,
                    'In Review',
                    Colors.purple.shade700,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(child: Text('No tasks found.'))
                : ListView.separated(
                    itemCount: filteredTasks.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade300),
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final priorityColor = getPriorityColor(task.priority);
                      final statusColor = getStatusColor(task.status);
                      final dueDateFormatted = DateFormat(
                        'EEE, d MMM y',
                      ).format(task.dueDate);
                      final assignedCount = task.assignedUsers?.length ?? 0;

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            _buildChip(task.priority, priorityColor),
                            SizedBox(width: 8),
                            _buildChip(task.status, statusColor),
                            SizedBox(width: 8),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              dueDateFormatted,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            Spacer(),
                            if (assignedCount > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      color: Colors.blue.shade700,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '$assignedCount',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          // Implement your task detail or edit here
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add, size: 32),
        onPressed: () async {
          final newTask = await Navigator.push<Task>(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(existingTasks: []),
            ),
          ); // Your screen

          if (newTask != null) {
            setState(() {
              tasks.add(newTask);
            });
            _saveTasks();
          }
        },
      ),
    );
  }
}

// Color brightness extension (same as yours)
extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }
}
