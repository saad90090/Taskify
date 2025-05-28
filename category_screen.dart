import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_drawer.dart'; // import the drawer

class CategoryScreen extends StatelessWidget {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _showCategoryDialog(BuildContext context,
      {DocumentSnapshot? categoryDoc}) async {
    final nameController =
        TextEditingController(text: categoryDoc?.get('name') ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(categoryDoc == null ? "New Category" : "Edit Category"),
        content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Category Name")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              final categoriesCollection = FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('categories');
              if (categoryDoc == null) {
                await categoriesCollection.add({'name': nameController.text});
              } else {
                await categoriesCollection
                    .doc(categoryDoc.id)
                    .update({'name': nameController.text});
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: Text("Categories")),
      drawer: AppDrawer(currentScreen: "Categories"),
      body: StreamBuilder<QuerySnapshot>(
        stream: categoriesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final categories = snapshot.data!.docs;
          if (categories.isEmpty) return Center(child: Text("No Categories"));

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.get('name')),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () =>
                          _showCategoryDialog(context, categoryDoc: category),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => category.reference.delete(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
