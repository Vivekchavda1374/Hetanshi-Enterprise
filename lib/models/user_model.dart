class UserModel {
  final String id;
  final String name;
  final String role; // 'Admin' or 'Salesman' or 'User'
  final String? email;
  final String? password; // Storing plain text as requested (Insecure)
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.password,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'email': email,
      'password': password,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      role: map['role'] ?? 'Salesman',
      email: map['email'],
      password: map['password'],
      isActive: map['isActive'] ?? true,
    );
  }
}
