class InicioResponse {
  final int reservasActivas;
  final int incidenciasPendientes;
  final int incidenciasUrgentes;
  final int tasaCobro;
  final int vecinosRegistrados;
  final List<OcupacionInstalacion> ocupacionInstalaciones;

  InicioResponse({
    required this.reservasActivas,
    required this.incidenciasPendientes,
    required this.incidenciasUrgentes,
    required this.tasaCobro,
    required this.vecinosRegistrados,
    required this.ocupacionInstalaciones,
  });

  factory InicioResponse.fromJson(Map<String, dynamic> json) {
    return InicioResponse(
      reservasActivas:      (json['reservas_activas'] as num).toInt(),
      incidenciasPendientes:(json['incidencias_pendientes'] as num).toInt(),
      incidenciasUrgentes:  (json['incidencias_urgentes'] as num).toInt(),
      tasaCobro:            (json['tasa_cobro'] as num).toInt(),
      vecinosRegistrados:   (json['vecinos_registrados'] as num).toInt(),
      ocupacionInstalaciones: (json['ocupacion_instalaciones'] as List)
          .map((e) => OcupacionInstalacion.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservas_activas':       reservasActivas,
      'incidencias_pendientes': incidenciasPendientes,
      'incidencias_urgentes':   incidenciasUrgentes,
      'tasa_cobro':             tasaCobro,
      'vecinos_registrados':    vecinosRegistrados,
      'ocupacion_instalaciones':
          ocupacionInstalaciones.map((e) => e.toJson()).toList(),
    };
  }
}

class OcupacionInstalacion {
  final String nombre;
  final String clave;
  final int porcentaje;

  OcupacionInstalacion({
    required this.nombre,
    required this.clave,
    required this.porcentaje,
  });

  factory OcupacionInstalacion.fromJson(Map<String, dynamic> json) {
    return OcupacionInstalacion(
      nombre:     json['nombre'] as String,
      clave:      json['clave'] as String,
      porcentaje: (json['porcentaje'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre':     nombre,
      'clave':      clave,
      'porcentaje': porcentaje,
    };
  }
}
