import 'dart:convert';
import 'dart:io';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/update_usuario_request.dart';
import 'package:app_mobile/core/interface/perfil_interface.dart';
import 'package:app_mobile/core/models/usuario_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class PerfilException implements Exception {
  final String message;
  const PerfilException(this.message);

  @override
  String toString() => message;
}

class PerfilService implements PerfilInterface {

  final String _url = '${ApiConstants.baseUrl}/usuarios';
  final TokenStorage _tokenStorage;

  PerfilService(this._tokenStorage);


  @override
  Future<UsuarioResponse> getUsuario(int id)async {
   try {
      final token = await _tokenStorage.getToken();
      final response = await http.get(
        Uri.parse('$_url/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return UsuarioResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        throw const PerfilException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const PerfilException('No tienes permiso para ver este perfil.');
      } else if (response.statusCode == 404) {
        throw const PerfilException('Usuario no encontrado.');
      } else {
        throw PerfilException('Error del servidor (${response.statusCode}).');
      }
    } on PerfilException {
      rethrow;
    } on SocketException {
      throw const PerfilException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw PerfilException('Error inesperado: $e');
    }
  }

  @override
  Future<UsuarioResponse> updateUsuario(int id, UpdateUsuarioRequest request) async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await http.put(
        Uri.parse('$_url/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return UsuarioResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        throw const PerfilException('Datos del perfil inválidos.');
      } else if (response.statusCode == 401) {
        throw const PerfilException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const PerfilException('No tienes permiso para modificar este perfil.');
      } else if (response.statusCode == 404) {
        throw const PerfilException('Usuario no encontrado.');
      } else {
        throw PerfilException('Error del servidor (${response.statusCode}).');
      }
    } on PerfilException {
      rethrow;
    } on SocketException {
      throw const PerfilException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw PerfilException('Error inesperado: $e');
    }
  }
}