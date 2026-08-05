class Quiz {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json["id"] as String,
      courseId: json["course_id"] as String,
      title: json["title"] as String,
      description: json["description"] as String? ?? "",
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "course_id": courseId,
      "title": title,
      "description": description,
    };
  }
}
