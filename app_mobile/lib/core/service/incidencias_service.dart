import 'dart:convert';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/incidencia_request.dart';
import 'package:app_mobile/core/interface/incidencias_interface.dart';
import 'package:app_mobile/core/models/incidencias_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class IncidenciasService implements IncidenciasInterface {
  final TokenStorage _tokenStorage;
  IncidenciasService(this._tokenStorage);

  @override
  Future<List<IncidenciasResponse>> getAllIncidencias() async {
    try {
      final url = "${ApiConstants.baseUrl}/incidencias";
      final token = await _tokenStorage.getToken();

      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
  

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        
        var incidencias = responseBody
            .map((e) => IncidenciasResponse.fromJson(e))
            .toList();
        return incidencias;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            "Error al obtener las incidencias: ${errorBody['message'] ?? 'Error desconocido'}");
      }
    } catch (e) {
      throw Exception("Error al obtener las incidencias: $e");
    }
  }

  @override
  Future<IncidenciasResponse> createIncidencia(IncidenciaRequest request) async {
    try {
      final url = "${ApiConstants.baseUrl}/incidencias";
      final token = await _tokenStorage.getToken();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(request.toFields()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return IncidenciasResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            "Error al crear la incidencia: ${errorBody['message'] ?? 'Error desconocido'}");
      }
    } catch (e) {
      throw Exception("Error al crear la incidencia: $e");
    }
  }

  @override
  Future<IncidenciasResponse> updateIncidencia(int id, IncidenciaRequest request) async {
    try {
      final url = "${ApiConstants.baseUrl}/incidencias/$id";
      final token = await _tokenStorage.getToken();

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(request.toFields()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return IncidenciasResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            "Error al actualizar la incidencia: ${errorBody['message'] ?? 'Error desconocido'}");
      }
    } catch (e) {
      throw Exception("Error al actualizar la incidencia: $e");
    }
  }

  @override
  Future<void> deleteIncidencia(int id) async {
    try {
      final url = "${ApiConstants.baseUrl}/incidencias/$id";
      final token = await _tokenStorage.getToken();

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            "Error al eliminar la incidencia: ${errorBody['message'] ?? 'Error desconocido'}");
      }
    } catch (e) {
      throw Exception("Error al eliminar la incidencia: $e");
    }
  }
}
