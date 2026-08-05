class Course {
  final String id;
  final String professorId;
  final String title;
  final String description;
  final String courseCode;

  Course({
    required this.id,
    required this.professorId,
    required this.title,
    required this.description,
    required this.courseCode,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json["id"],
      professorId: json["professor_id"],
      title: json["title"],
      description: json["description"] ?? "",
      courseCode: json["course_code"] ?? "",
    );
  }
}
