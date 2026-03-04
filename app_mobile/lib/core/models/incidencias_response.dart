class IncidenciasResponse {
  final int id;
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String categoria;
  final String prioridad;
  final String estado;
  final int usuarioId;
  final int? viviendaId;
  final DateTime? fechaResolucion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? foto; 

  IncidenciasResponse({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.categoria,
    required this.prioridad,
    required this.estado,
    required this.usuarioId,
    this.viviendaId,
    this.fechaResolucion,
    required this.createdAt,
    required this.updatedAt,
    this.foto, // ← nuevo
  });

 factory IncidenciasResponse.fromJson(Map<String, dynamic> json) {
  return IncidenciasResponse(
    id:          int.parse(json['id'].toString()),           // ← fix
    titulo:      json['titulo'] as String,
    descripcion: json['descripcion'] as String,
    ubicacion:   json['ubicacion'] as String,
    categoria:   json['categoria'] as String,
    prioridad:   json['prioridad'] as String,
    estado:      json['estado'] as String,
    usuarioId:   int.parse(json['usuario_id'].toString()),   // ← fix
    viviendaId:  json['vivienda_id'] != null
        ? int.parse(json['vivienda_id'].toString())          // ← fix
        : null,
    fechaResolucion: json['fecha_resolucion'] != null
        ? DateTime.parse(json['fecha_resolucion'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    foto:      json['foto'] as String?,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id':               id,
      'titulo':           titulo,
      'descripcion':      descripcion,
      'ubicacion':        ubicacion,
      'categoria':        categoria,
      'prioridad':        prioridad,
      'estado':           estado,
      'usuario_id':       usuarioId,
      'vivienda_id':      viviendaId,
      'fecha_resolucion': fechaResolucion?.toIso8601String(),
      'created_at':       createdAt.toIso8601String(),
      'updated_at':       updatedAt.toIso8601String(),
      'foto':             foto, // ← nuevo
    };
  }
}
