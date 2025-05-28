import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'project_form_screen.dart';

class ProjectListScreen extends StatefulWidget {
  final String statusFilter;

  const ProjectListScreen({Key? key, required this.statusFilter})
      : super(key: key);

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late CollectionReference projectsRef;

  @override
  void initState() {
    super.initState();
    if (userId == null) throw Exception('User not logged in');
    projectsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('projects');
  }

  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    await projectsRef.doc(projectId).update({'status': newStatus});
  }

  Future<void> deleteProject(String projectId) async {
    await projectsRef.doc(projectId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.statusFilter} Projects'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: projectsRef
            .where('status', isEqualTo: widget.statusFilter)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No projects found.'));
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final doc = projects[index];
              final data = doc.data()! as Map<String, dynamic>;
              final name = data['name'] ?? 'No Name';
              final dueDateTimestamp = data['dueDate'] as Timestamp?;
              final dueDate =
                  dueDateTimestamp != null ? dueDateTimestamp.toDate() : null;
              final isDone = data['status'] == 'Completed';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(name),
                  subtitle: dueDate != null
                      ? Text(
                          'Due: ${dueDate.toLocal().toString().split(' ')[0]}')
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Checkbox for done/not done
                      Checkbox(
                        value: isDone,
                        onChanged: (checked) async {
                          final newStatus =
                              checked! ? 'Completed' : widget.statusFilter;
                          await updateProjectStatus(doc.id, newStatus);
                        },
                      ),
                      // Edit button
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectFormScreen(
                                isEditing: true,
                                projectId: doc.id,
                                existingData: data,
                              ),
                            ),
                          );
                        },
                      ),
                      // Delete button
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Delete Project'),
                              content: Text(
                                  'Are you sure you want to delete this project?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await deleteProject(doc.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
