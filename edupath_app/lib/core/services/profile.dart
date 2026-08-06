class Profile {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;

  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map["id"],
      fullName: map["full_name"] ?? "",
      email: map["email"] ?? "",
      role: map["role"] ?? "",
      avatarUrl: map["avatar_url"],
    );
  }
}
