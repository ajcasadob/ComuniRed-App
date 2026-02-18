class ReservaResponse {
  final int id;
  final String nombreEspacio;
  final int usuarioId;
  final String fechaReserva;
  final String horaInicio;
  final String horaFin;
  final String estado;
  final String createdAt;
  final String updatedAt;
  final Usuario usuario;

  ReservaResponse({
    required this.id,
    required this.nombreEspacio,
    required this.usuarioId,
    required this.fechaReserva,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    required this.usuario,
  });

  factory ReservaResponse.fromJson(Map<String, dynamic> json) {
    return ReservaResponse(
      id: json['id'] as int,
      nombreEspacio: json['nombre_espacio'] as String,
      usuarioId: json['usuario_id'] as int,
      fechaReserva: json['fecha_reserva'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      estado: json['estado'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      usuario: Usuario.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_espacio': nombreEspacio,
      'usuario_id': usuarioId,
      'fecha_reserva': fechaReserva,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'estado': estado,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'usuario': usuario.toJson(),
    };
  }
}

class Usuario {
  final int id;
  final String name;
  final String email;
  final dynamic viviendaId;
  final String role;
  final dynamic emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final dynamic vivienda;

  Usuario({
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

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      viviendaId: json['vivienda_id'],
      role: json['role'] as String,
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      vivienda: json['vivienda'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'vivienda_id': viviendaId,
      'role': role,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'vivienda': vivienda,
    };
  }
}