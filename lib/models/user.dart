class User {
  final String id;
  final String name;
  final String surname;
  final String email;
  final String username;
  final String registrationDate;
  final bool verified;
  final String role;
  const User(
    this.id,
    this.name,
    this.surname,
    this.email,
    this.username,
    this.registrationDate,
    this.verified,
    this.role,
  );
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['name'],
      json['surname'],
      json['email'],
      json['username'],
      json['registrationDate'],
      json['verified'],
      json['role'],
    );
  }
}
