
class UserEntity {
  final String id;
  final String email;
  final String? nombres;
  final String? apellidos;
  final String? telefono;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final bool isEmailConfirmed;
  final String? accessToken;

  const UserEntity({
    required this.id,
    required this.email,
    this.nombres,
    this.apellidos,
    this.telefono,
    this.avatarUrl,
    this.createdAt,
    this.lastSignInAt,
    this.isEmailConfirmed = false,
    this.accessToken,
  });

  factory UserEntity.fromSupabaseData({
    required String id,
    required String email,
    Map<String, dynamic>? userMetadata,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    DateTime? confirmedAt,
    String? accessToken,
  }) {
    return UserEntity(
      id: id,
      email: email,
      nombres: userMetadata?['nombres'] as String?,
      apellidos: userMetadata?['apellidos'] as String?,
      telefono: userMetadata?['telefono'] as String?,
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
      isEmailConfirmed: confirmedAt != null,
      accessToken: accessToken,
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? json['user_id'] ?? '',
      email: json['email'] ?? '',
      nombres: json['nombres'] as String?,
      apellidos: json['apellidos'] as String?,
      telefono: json['telefono'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
      lastSignInAt: json['last_sign_in_at'] != null 
          ? DateTime.tryParse(json['last_sign_in_at']) 
          : null,
      isEmailConfirmed: json['confirmed_at'] != null,
      accessToken: json['access_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombres': nombres,
      'apellidos': apellidos,
      'telefono': telefono,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
      'is_email_confirmed': isEmailConfirmed,
      'access_token': accessToken,
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? nombres,
    String? apellidos,
    String? telefono,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? isEmailConfirmed,
    String? accessToken,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      telefono: telefono ?? this.telefono,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  String get fullName => '$nombres $apellidos'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : email;
  bool get hasCompletedProfile => nombres != null && apellidos != null;
}