import 'package:app_mobile/core/models/incidencias_response.dart';

abstract class IncidenciasInterface {
  Future<List<IncidenciasResponse>> getAllIncidencias();
}