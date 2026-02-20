class AvisosResponse {
  final int id;
  final String titulo;
  final String contenido;
  final String tipo;
  final int autorId;
  final String fechaPublicacion;
  final int activa;
  final String createdAt;
  final String updatedAt;

  AvisosResponse({
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

  factory AvisosResponse.fromJson(Map<String, dynamic> json) {
    return AvisosResponse(
      id: json['id'],
      titulo: json['titulo'],
      contenido: json['contenido'],
      tipo: json['tipo'],
      autorId: json['autor_id'],
      fechaPublicacion: json['fecha_publicacion'],
      activa: json['activa'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}