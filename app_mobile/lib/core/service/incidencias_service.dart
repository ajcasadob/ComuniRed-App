import 'dart:convert';
import 'dart:io';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/incidencia_request.dart';
import 'package:app_mobile/core/interface/incidencias_interface.dart';
import 'package:app_mobile/core/models/incidencias_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class IncidenciasException implements Exception {
  final String message;
  const IncidenciasException(this.message);

  @override
  String toString() => message;
}

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
        return responseBody.map((e) => IncidenciasResponse.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw const IncidenciasException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const IncidenciasException('No tienes permiso para ver las incidencias.');
      } else if (response.statusCode == 404) {
        throw const IncidenciasException('Recurso no encontrado.');
      } else {
        throw IncidenciasException('Error del servidor (${response.statusCode}).');
      }
    } on IncidenciasException {
      rethrow;
    } on SocketException {
      throw const IncidenciasException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw IncidenciasException('Error inesperado: $e');
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
      } else if (response.statusCode == 400) {
        throw const IncidenciasException('Datos de la incidencia inválidos.');
      } else if (response.statusCode == 401) {
        throw const IncidenciasException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const IncidenciasException('No tienes permiso para crear incidencias.');
      } else {
        throw IncidenciasException('Error del servidor (${response.statusCode}).');
      }
    } on IncidenciasException {
      rethrow;
    } on SocketException {
      throw const IncidenciasException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw IncidenciasException('Error inesperado: $e');
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
      } else if (response.statusCode == 400) {
        throw const IncidenciasException('Datos de la incidencia inválidos.');
      } else if (response.statusCode == 401) {
        throw const IncidenciasException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const IncidenciasException('No tienes permiso para modificar esta incidencia.');
      } else if (response.statusCode == 404) {
        throw const IncidenciasException('Incidencia no encontrada.');
      } else {
        throw IncidenciasException('Error del servidor (${response.statusCode}).');
      }
    } on IncidenciasException {
      rethrow;
    } on SocketException {
      throw const IncidenciasException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw IncidenciasException('Error inesperado: $e');
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else if (response.statusCode == 401) {
        throw const IncidenciasException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const IncidenciasException('No tienes permiso para eliminar esta incidencia.');
      } else if (response.statusCode == 404) {
        throw const IncidenciasException('Incidencia no encontrada.');
      } else {
        throw IncidenciasException('Error del servidor (${response.statusCode}).');
      }
    } on IncidenciasException {
      rethrow;
    } on SocketException {
      throw const IncidenciasException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw IncidenciasException('Error inesperado: $e');
    }
  }
}
