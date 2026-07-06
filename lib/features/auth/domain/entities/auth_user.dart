class AuthUser {
  final String id;
  final String email;
  final String role;

  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
  });

  @override
  String toString() => 'AuthUser(id: $id, email: $email, role: $role)';
}
