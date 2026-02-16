class AvisoResponse {
  final int id;
  final String titulo;
  final String contenido;
  final String tipo;
  final int autorId;
  final String fechaPublicacion;
  final int activa;
  final DateTime createdAt;
  final DateTime updatedAt;

  AvisoResponse({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.tipo,
    required this.autorId,
    required this.fechaPublicacion,
    required this.activa,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AvisoResponse.fromJson(Map<String, dynamic> json) {
    return AvisoResponse(
      id: json['id'],
      titulo: json['titulo'],
      contenido: json['contenido'],
      tipo: json['tipo'],
      autorId: json['autor_id'],
      fechaPublicacion: json['fecha_publicacion'],
      activa: json['activa'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'tipo': tipo,
      'autor_id': autorId,
      'fecha_publicacion': fechaPublicacion,
      'activa': activa,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}