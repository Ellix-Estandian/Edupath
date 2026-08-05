class LearningMaterial {
  final String id;
  final String courseId;
  final String fileName;
  final String filePath;
  final String fileType;

  LearningMaterial({
    required this.id,
    required this.courseId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
  });

  factory LearningMaterial.fromJson(Map<String, dynamic> json) {
    return LearningMaterial(
      id: json["id"] as String,
      courseId: json["course_id"] as String,
      fileName: json["file_name"] as String,
      filePath: json["file_path"] as String,
      fileType: json["file_type"] as String,
    );
  }
}
