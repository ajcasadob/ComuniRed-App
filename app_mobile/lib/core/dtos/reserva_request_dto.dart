class CrearReservaRequest {
  final String nombreEspacio;
  final int usuarioId;
  final String fechaReserva;
  final String horaInicio;
  final String horaFin;
  final String estado;

  CrearReservaRequest({
    required this.nombreEspacio,
    required this.usuarioId,
    required this.fechaReserva,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
  });

  Map<String, dynamic> toJson() => {
    'nombre_espacio': nombreEspacio,
    'usuario_id': usuarioId,
    'fecha_reserva': fechaReserva,
    'hora_inicio': horaInicio,
    'hora_fin': horaFin,
    'estado': estado,
  };
}
