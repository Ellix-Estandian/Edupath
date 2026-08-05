class Profile {
  final String id;
  final String fullName;
  final String email;
  final String role;

  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json["id"],
      fullName: json["full_name"],
      email: json["email"],
      role: json["role"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "full_name": fullName,
      "email": email,
      "role": role,
    };
  }
}
