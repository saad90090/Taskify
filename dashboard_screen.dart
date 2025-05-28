import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_drawer.dart';
import 'project_list_screen.dart';
import 'project_form_screen.dart';

class ProjectDashboardScreen extends StatefulWidget {
  @override
  _ProjectDashboardScreenState createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  DateTime? _selectedDateTime;
  final TextEditingController _agendaController = TextEditingController();

  void _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _showCallMeetingDialog() {
    _agendaController.clear();
    _selectedDateTime = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Schedule a Meeting"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _agendaController,
                decoration: InputDecoration(labelText: "Meeting Agenda"),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDateTime == null
                          ? "No date & time selected"
                          : "Scheduled for: ${_selectedDateTime!.toLocal()}",
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDateTime,
                    child: Text("Pick Date & Time"),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_selectedDateTime == null || _agendaController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("Please select date/time and enter agenda")),
                );
                return;
              }

              // TODO: Save meeting info to Firestore or backend here
              print(
                  "Meeting scheduled at $_selectedDateTime with agenda: ${_agendaController.text}");

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Meeting scheduled!")),
              );
            },
            child: Text("Schedule"),
          ),
        ],
      ),
    );
  }

  Widget buildBox(BuildContext context, String title, int count, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
              SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectListScreen(statusFilter: title),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final projectsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('projects')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      drawer: AppDrawer(currentScreen: "Projects"),
      body: StreamBuilder<QuerySnapshot>(
        stream: projectsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          int inProgress = 0, inReview = 0, onHold = 0, completed = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? '';

            switch (status) {
              case 'In Progress':
                inProgress++;
                break;
              case 'In Review':
                inReview++;
                break;
              case 'On Hold':
                onHold++;
                break;
              case 'Completed':
                completed++;
                break;
            }
          }

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dashboard",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Project Summary",
                    style: TextStyle(fontSize: 20, color: Colors.grey[700])),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      buildBox(
                          context, "In Progress", inProgress, Colors.orange),
                      buildBox(context, "In Review", inReview, Colors.blue),
                      buildBox(context, "On Hold", onHold, Colors.redAccent),
                      buildBox(context, "Completed", completed, Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: "addProjectBtn",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(isEditing: false),
                ),
              );
            },
            icon: Icon(Icons.add),
            label: Text("Add Project"),
          ),
          SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "callMeetingBtn",
            onPressed: _showCallMeetingDialog,
            icon: Icon(Icons.video_call),
            label: Text("Call Meeting"),
            backgroundColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}
