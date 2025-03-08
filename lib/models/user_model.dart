class User {
  final int id;
  final String name;
  final String email;
  final String? username;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'username': username,
      };
}
