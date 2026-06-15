class OAuthTokenDto {
  final String? accessToken;
  final String? idToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const OAuthTokenDto({this.accessToken, this.idToken, this.refreshToken, this.expiresAt});

  Map<String, dynamic> toJson() => {
    if (accessToken != null) 'accessToken': accessToken,
    if (idToken != null) 'idToken': idToken,
    if (refreshToken != null) 'refreshToken': refreshToken,
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
  };

  factory OAuthTokenDto.fromJson(Map<String, dynamic> j) => OAuthTokenDto(
    accessToken: j['accessToken'] as String?, idToken: j['idToken'] as String?,
    refreshToken: j['refreshToken'] as String?,
    expiresAt: j['expiresAt'] != null ? DateTime.parse(j['expiresAt'] as String) : null,
  );
}
