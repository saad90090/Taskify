import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectFormScreen extends StatefulWidget {
  final bool isEditing;
  final String? projectId;
  final Map<String, dynamic>? existingData;

  const ProjectFormScreen({
    Key? key,
    required this.isEditing,
    this.projectId,
    this.existingData,
  }) : super(key: key);

  @override
  _ProjectFormScreenState createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  String _status = 'In Progress';

  CollectionReference get projectsRef {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('projects');
  }

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingData?['name'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingData?['description'] ?? '');
    final dueTimestamp = widget.existingData?['dueDate'];
    if (dueTimestamp is Timestamp) {
      _dueDate = dueTimestamp.toDate();
    } else {
      _dueDate = null;
    }
    _status = widget.existingData?['status'] ?? 'In Progress';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(Duration(days: 365 * 5)),
      lastDate: now.add(Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    final data = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'dueDate': Timestamp.fromDate(_dueDate!),
      'status': _status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.isEditing && widget.projectId != null) {
        await projectsRef.doc(widget.projectId).update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await projectsRef.add(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save project: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Project' : 'Add Project'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Project Name'),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Please enter project name'
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              ListTile(
                title: Text(_dueDate != null
                    ? 'Due Date: ${_dueDate!.toLocal().toString().split(' ')[0]}'
                    : 'Select Due Date'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDueDate,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['In Progress', 'In Review', 'On Hold', 'Completed']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProject,
                child:
                    Text(widget.isEditing ? 'Update Project' : 'Add Project'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
