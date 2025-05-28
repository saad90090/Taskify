import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'project.dart';

final projectProvider = StreamProvider<List<Project>>((ref) {
  return FirebaseFirestore.instance.collection('projects').snapshots().map(
      (snap) =>
          snap.docs.map((doc) => Project.fromMap(doc.id, doc.data())).toList());
});
