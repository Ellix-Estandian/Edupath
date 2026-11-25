class Quiz {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime createdAt;
  final int? durationMinutes;
  final DateTime? availableFrom;
  final DateTime? availableUntil;

  Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.durationMinutes,
    this.availableFrom,
    this.availableUntil,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json["id"] as String,
      courseId: json["course_id"] as String,
      title: json["title"] as String,
      description: json["description"] as String? ?? "",
      createdAt: DateTime.parse(json["created_at"]),
      durationMinutes: json['duration_minutes'] as int?,
      availableFrom: json['available_from'] == null ? null : DateTime.parse(json['available_from']),
      availableUntil: json['available_until'] == null ? null : DateTime.parse(json['available_until']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "course_id": courseId,
      "title": title,
      "description": description,
      "duration_minutes": durationMinutes,
      "available_from": availableFrom?.toUtc().toIso8601String(),
      "available_until": availableUntil?.toUtc().toIso8601String(),
    };
  }

  bool get isAvailableNow {
    final now = DateTime.now();
    return (availableFrom == null || !now.isBefore(availableFrom!)) &&
        (availableUntil == null || now.isBefore(availableUntil!));
  }
}
