import 'package:app_mobile/core/dtos/incidencia_request.dart';
import 'package:app_mobile/core/models/incidencias_response.dart';

abstract class IncidenciasInterface {
  Future<List<IncidenciasResponse>> getAllIncidencias();
  Future<IncidenciasResponse> createIncidencia(IncidenciaRequest request);
}