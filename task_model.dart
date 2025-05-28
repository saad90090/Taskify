import 'dart:convert';

class Task {
  String? id;
  final String title;
  final String priority;
  final String status;
  final String? progressStatus;
  final DateTime dueDate;
  final int linkedTasks;
  final int comments;
  final List<String> assignedUsers;

  Task({
    this.id,
    required this.title,
    required this.priority,
    required this.status,
    this.progressStatus,
    required this.dueDate,
    required this.linkedTasks,
    required this.comments,
    required this.assignedUsers,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'priority': priority,
        'status': status,
        'progressStatus': progressStatus,
        'dueDate': dueDate.toIso8601String(),
        'linkedTasks': linkedTasks,
        'comments': comments,
        'assignedUsers': assignedUsers,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        title: map['title'],
        priority: map['priority'],
        status: map['status'],
        progressStatus: map['progressStatus'],
        dueDate: DateTime.parse(map['dueDate']),
        linkedTasks: map['linkedTasks'],
        comments: map['comments'],
        assignedUsers: List<String>.from(map['assignedUsers']),
      );

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  Task copyWith({
    String? id,
    String? title,
    String? priority,
    String? status,
    String? progressStatus,
    DateTime? dueDate,
    int? linkedTasks,
    int? comments,
    List<String>? assignedUsers,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      progressStatus: progressStatus ?? this.progressStatus,
      dueDate: dueDate ?? this.dueDate,
      linkedTasks: linkedTasks ?? this.linkedTasks,
      comments: comments ?? this.comments,
      assignedUsers: assignedUsers ?? this.assignedUsers,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: $priority, status: $status, progressStatus: $progressStatus, dueDate: $dueDate, linkedTasks: $linkedTasks, comments: $comments, assignedUsers: $assignedUsers)';
  }
}
