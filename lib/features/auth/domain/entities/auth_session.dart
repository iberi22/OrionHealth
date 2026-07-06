class AuthSession {
  final String token;
  final DateTime expiresAt;

  const AuthSession({
    required this.token,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  String toString() => 'AuthSession(token: $token, expiresAt: $expiresAt)';
}
