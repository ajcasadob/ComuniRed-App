class IncidenciaRequest {
  final String titulo;
  final String descripcion;
  final String ubicacion;
  final String categoria;
  final String estado;
  final String prioridad;
 
  final int usuarioId;
  final int? viviendaId;
  final DateTime? fechaResolucion;

  IncidenciaRequest({
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.categoria,
    this.estado = 'pendiente',
    this.prioridad = 'baja',
    required this.usuarioId,
    this.viviendaId,
    this.fechaResolucion,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'categoria': categoria,
      'estado': estado,
      'prioridad': prioridad,
      'usuario_id': usuarioId,
      'vivienda_id': viviendaId,
      'fecha_resolucion': fechaResolucion?.toIso8601String(),
    };
  }
}
