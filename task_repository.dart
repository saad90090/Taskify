import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_model.dart';

class TaskRepository {
  Future<List<Task>> fetchUserTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final tasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks');

    final snapshot = await tasksRef.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Task.fromMap(data).copyWith(id: doc.id);
    }).toList();
  }
}
