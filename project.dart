class Project {
  String id;
  String title;
  String status;
  List<String> members;

  Project(
      {required this.id,
      required this.title,
      required this.status,
      required this.members});

  factory Project.fromMap(String id, Map<String, dynamic> data) => Project(
        id: id,
        title: data['title'],
        status: data['status'],
        members: List<String>.from(data['members']),
      );
}
