import 'dart:convert';
import 'dart:io';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/interface/avisos_interface.dart';
import 'package:app_mobile/core/models/avisos_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class AvisosException implements Exception {
  final String message;
  const AvisosException(this.message);

  @override
  String toString() => message;
}

class AvisosService implements AvisosInterface {

  final TokenStorage _tokenStorage;
  AvisosService(this._tokenStorage);

  @override
  Future<List<AvisosResponse>> getAllAvisos() async {
    try {
      final url = "${ApiConstants.baseUrl}/comunicaciones";
      final token = await _tokenStorage.getToken();

      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        return responseBody.map((e) => AvisosResponse.fromJson(e)).toList();
      } else if (response.statusCode == 401) {
        throw const AvisosException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const AvisosException('No tienes permiso para ver los avisos.');
      } else if (response.statusCode == 404) {
        throw const AvisosException('Recurso no encontrado.');
      } else {
        throw AvisosException('Error del servidor (${response.statusCode}).');
      }
    } on AvisosException {
      rethrow;
    } on SocketException {
      throw const AvisosException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw AvisosException('Error inesperado: $e');
    }
  }
}
