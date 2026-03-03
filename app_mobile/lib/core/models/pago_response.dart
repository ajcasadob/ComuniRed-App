class PagoResponse {
  final int id;
  final int viviendaId;
  final String concepto;
  final String periodo;
  final double importe;
  final String estado;
  final DateTime fechaVencimiento;
  final DateTime? fechaPago;
  final ViviendaPago vivienda;
  final DateTime createdAt;
  final DateTime updatedAt;

  PagoResponse({
    required this.id,
    required this.viviendaId,
    required this.concepto,
    required this.periodo,
    required this.importe,
    required this.estado,
    required this.fechaVencimiento,
    this.fechaPago,
    required this.vivienda,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PagoResponse.fromJson(Map<String, dynamic> json) {
    return PagoResponse(
      id:               (json['id'] as num).toInt(),
      viviendaId:       (json['vivienda_id'] as num).toInt(),
      concepto:         json['concepto'] as String,
      periodo:          json['periodo'] as String,
      importe:          double.parse(json['importe'].toString()),
      estado:           json['estado'] as String,
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento'] as String),
      fechaPago:        json['fecha_pago'] != null
          ? DateTime.parse(json['fecha_pago'] as String)
          : null,
      vivienda:  ViviendaPago.fromJson(json['vivienda']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class ViviendaPago {
  final int id;
  final String numeroVivienda;
  final String bloque;
  final String piso;
  final String puerta;
  final double metrosCuadrados;
  final String tipo;

  ViviendaPago({
    required this.id,
    required this.numeroVivienda,
    required this.bloque,
    required this.piso,
    required this.puerta,
    required this.metrosCuadrados,
    required this.tipo,
  });

  factory ViviendaPago.fromJson(Map<String, dynamic> json) {
    return ViviendaPago(
      id:              (json['id'] as num).toInt(),
      numeroVivienda:  json['numero_vivienda'] as String,
      bloque:          json['bloque'] as String,
      piso:            json['piso'] as String,
      puerta:          json['puerta'] as String,
      metrosCuadrados: double.parse(json['metros_cuadrados'].toString()),
      tipo:            json['tipo'] as String,
    );
  }
}
