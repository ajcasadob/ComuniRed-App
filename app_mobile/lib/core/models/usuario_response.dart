class UsuarioResponse {
  final int id;
  final String name;
  final String email;
  final int? viviendaId;
  final String role;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final ViviendaPerfil? vivienda;

  UsuarioResponse({
    required this.id,
    required this.name,
    required this.email,
    this.viviendaId,
    required this.role,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.vivienda,
  });

  factory UsuarioResponse.fromJson(Map<String, dynamic> json) {
    return UsuarioResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      viviendaId: json['vivienda_id'] as int?,
      role: json['role'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      vivienda: json['vivienda'] != null
          ? ViviendaPerfil.fromJson(json['vivienda'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ViviendaPerfil {
  final int id;
  final String numeroVivienda;
  final String bloque;
  final String piso;
  final String puerta;
  final String metrosCuadrados;
  final String tipo;

  ViviendaPerfil({
    required this.id,
    required this.numeroVivienda,
    required this.bloque,
    required this.piso,
    required this.puerta,
    required this.metrosCuadrados,
    required this.tipo,
  });

  factory ViviendaPerfil.fromJson(Map<String, dynamic> json) {
    return ViviendaPerfil(
      id: json['id'] as int,
      numeroVivienda: json['numero_vivienda'] as String,
      bloque: json['bloque'] as String,
      piso: json['piso'] as String,
      puerta: json['puerta'] as String,
      metrosCuadrados: json['metros_cuadrados'] as String,
      tipo: json['tipo'] as String,
    );
  }
}
