import 'dart:convert';
import 'dart:io';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/interface/inicio_interface.dart';
import 'package:app_mobile/core/models/inicio_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class InicioException implements Exception {
  final String message;
  const InicioException(this.message);

  @override
  String toString() => message;
}

class InicioService implements InicioInterface {

final TokenStorage _tokenStorage;
    InicioService(this._tokenStorage);


  @override
  Future<InicioResponse> getAll() async {
  
    try{
      final url = "${ApiConstants.baseUrl}/dashboard/estadisticas";
      final token = await _tokenStorage.getToken();

      final response = await http.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      }
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        return InicioResponse.fromJson(responseBody);
      } else if (response.statusCode == 401) {
        throw const InicioException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const InicioException('No tienes permiso para ver las estadísticas.');
      } else if (response.statusCode == 404) {
        throw const InicioException('Recurso no encontrado.');
      } else {
        throw InicioException('Error del servidor (${response.statusCode}).');
      }
    } on InicioException {
      rethrow;
    } on SocketException {
      throw const InicioException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw InicioException('Error inesperado: $e');
    }
  }
}