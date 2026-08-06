class Presentation {
  final String id;
  final String courseId;
  final String title;
  final String topic;
  final String filePath;
  final DateTime createdAt;

  Presentation({
    required this.id,
    required this.courseId,
    required this.title,
    required this.topic,
    required this.filePath,
    required this.createdAt,
  });

  factory Presentation.fromJson(Map<String, dynamic> json) {
    return Presentation(
      id: json["id"],
      courseId: json["course_id"],
      title: json["title"],
      topic: json["topic"],
      filePath: json["file_path"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
