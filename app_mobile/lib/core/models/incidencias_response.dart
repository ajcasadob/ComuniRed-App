class IncidenciasResponse {
  final int id;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String categoria;
  final String estado;
  final int usuarioId;
  final int viviendaId;
  final DateTime? fechaResolucion;
  final DateTime createdAt;
  final DateTime updatedAt;

  IncidenciasResponse({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.categoria,
    required this.estado,
    required this.usuarioId,
    required this.viviendaId,
    this.fechaResolucion,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IncidenciasResponse.fromJson(Map<String, dynamic> json) {
    return IncidenciasResponse(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      ubicacion: json['ubicacion'] as String,
      categoria: json['categoria'] as String,
      estado: json['estado'] as String,
      usuarioId: json['usuario_id'] as int,
      viviendaId: json['vivienda_id'] as int,
      fechaResolucion: json['fecha_resolucion'] != null
          ? DateTime.parse(json['fecha_resolucion'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'categoria': categoria,
      'estado': estado,
      'usuario_id': usuarioId,
      'vivienda_id': viviendaId,
      'fecha_resolucion': fechaResolucion?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}