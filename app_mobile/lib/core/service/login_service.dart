import 'dart:convert';
import 'dart:io';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/login_request_dto.dart';
import 'package:app_mobile/core/interface/login_interface.dart';
import 'package:app_mobile/core/models/login_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class LoginException implements Exception {
  final String message;
  const LoginException(this.message);

  @override
  String toString() => message;
}

class LoginService implements LoginInterface {

  final TokenStorage _tokenStorage;
  LoginService(this._tokenStorage);

  @override
  Future<LoginResponse> login(LoginRequestDto request) async {
    try {
      final url = "${ApiConstants.baseUrl}/login";

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(responseBody);
        await _tokenStorage.saveToken(loginResponse.token);
        await _tokenStorage.saveUserId(loginResponse.user.id);
        await _tokenStorage.saveViviendaId(loginResponse.user.viviendaId);
        await _tokenStorage.saveNombre(loginResponse.user.name);
        return loginResponse;
      } else if (response.statusCode == 400) {
        throw const LoginException('Credenciales inválidas. Revisa los campos.');
      } else if (response.statusCode == 401) {
        throw const LoginException('Usuario o contraseña incorrectos.');
      } else if (response.statusCode == 403) {
        throw const LoginException('Cuenta suspendida o sin permisos.');
      } else if (response.statusCode == 422) {
        throw const LoginException('Correo o contraseña incorrectos.');
      } else {
        throw LoginException('Error del servidor (${response.statusCode}).');
      }
    } on LoginException {
      rethrow;
    } on SocketException {
      throw const LoginException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw LoginException('Error inesperado: $e');
    }
  }
}