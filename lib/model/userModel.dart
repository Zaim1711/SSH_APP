class User {
  final int id;
  final String username;
  final String email;
  final String profileImage; // Attribute for profile image

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'],
      profileImage:
          json['profile_image'] ?? '', // Get profile image URL from JSON
    );
  }
}
