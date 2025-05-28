import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';

final categoryProvider = StreamProvider<List<Category>>((ref) {
  return FirebaseFirestore.instance.collection('categories').snapshots().map(
      (snap) => snap.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList());
});
