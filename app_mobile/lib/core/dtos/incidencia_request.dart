import 'dart:io';

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
  final File? foto; 

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
    this.foto, // ← nuevo
  });

  Map<String, String> toFields() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'categoria': categoria,
      'estado': estado,
      'prioridad': prioridad,
      'usuario_id': usuarioId.toString(),
      if (viviendaId != null) 'vivienda_id': viviendaId.toString(),
      if (fechaResolucion != null)
        'fecha_resolucion': fechaResolucion!.toIso8601String(),
    };
  }
}
