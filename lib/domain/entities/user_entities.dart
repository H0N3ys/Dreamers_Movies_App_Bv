
class UserEntity {
  final String id;
  final String email;
  final String? nombres;
  final String? apellidos;
  final String? telefono;
  final String? avatarUrl;
  final String? idiomaPreferido;
  final bool restriccionInfantil;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final bool isEmailConfirmed;
  final String? accessToken;
  final int? nivelPermiso; 

  const UserEntity({
    required this.id,
    required this.email,
    this.nombres,
    this.apellidos,
    this.telefono,
    this.avatarUrl,
    this.idiomaPreferido,
    this.restriccionInfantil = false,
    this.createdAt,
    this.lastSignInAt,
    this.isEmailConfirmed = false,
    this.accessToken,
    this.nivelPermiso,
  });

  
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id_usuario'].toString(),
      email: json['email'] ?? '',
      nombres: json['nombres'] as String?,
      apellidos: json['apellidos'] as String?,
      telefono: json['telefono'] as String?,
      createdAt: json['fecha_registro'] != null 
          ? DateTime.tryParse(json['fecha_registro']) 
          : null,
      isEmailConfirmed: true,
    );
  }

  
  factory UserEntity.fromPerfil(Map<String, dynamic> usuario, Map<String, dynamic> perfil) {
    return UserEntity(
      id: usuario['id_usuario'].toString(),
      email: usuario['email'] ?? '',
      nombres: perfil['nombre_perfil'] ?? usuario['nombres'],
      apellidos: usuario['apellidos'] as String?,
      telefono: usuario['telefono'] as String?,
      avatarUrl: perfil['avatar_url'] as String?,
      idiomaPreferido: perfil['idioma_preferido'] as String?,
      restriccionInfantil: perfil['restriccion_infantil'] == 1,
      createdAt: usuario['fecha_registro'] != null 
          ? DateTime.tryParse(usuario['fecha_registro']) 
          : null,
      isEmailConfirmed: true,
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
      'idioma_preferido': idiomaPreferido,
      'restriccion_infantil': restriccionInfantil ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'is_email_confirmed': isEmailConfirmed,
      'nivel_permiso': nivelPermiso,
    };
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? nombres,
    String? apellidos,
    String? telefono,
    String? avatarUrl,
    String? idiomaPreferido,
    bool? restriccionInfantil,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? isEmailConfirmed,
    String? accessToken,
    int? nivelPermiso,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      telefono: telefono ?? this.telefono,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      idiomaPreferido: idiomaPreferido ?? this.idiomaPreferido,
      restriccionInfantil: restriccionInfantil ?? this.restriccionInfantil,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      isEmailConfirmed: isEmailConfirmed ?? this.isEmailConfirmed,
      accessToken: accessToken ?? this.accessToken,
      nivelPermiso: nivelPermiso ?? this.nivelPermiso,
    );
  }

  String get fullName => '$nombres $apellidos'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : email;
  bool get hasCompletedProfile => nombres != null && apellidos != null;
  bool get isAdmin => nivelPermiso != null;
}