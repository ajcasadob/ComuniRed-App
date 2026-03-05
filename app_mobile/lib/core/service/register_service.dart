import 'dart:convert';
import 'dart:io';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/register_request_dto.dart';
import 'package:app_mobile/core/interface/register_interface.dart';
import 'package:app_mobile/core/models/register_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class RegisterException implements Exception {
  final String message;
  const RegisterException(this.message);

  @override
  String toString() => message;
}

class RegisterService implements RegisterInterface {

  final TokenStorage _tokenStorage;
  RegisterService(this._tokenStorage);

  @override
  Future<RegisterResponse> register(RegisterRequestDto request) async {
    try {
      final url = "${ApiConstants.baseUrl}/register";

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
        final registerResponse = RegisterResponse.fromJson(responseBody);
        await _tokenStorage.saveToken(registerResponse.token);
        return registerResponse;
      } else if (response.statusCode == 400) {
        throw const RegisterException('Datos de registro inválidos. Revisa los campos.');
      } else if (response.statusCode == 409) {
        throw const RegisterException('El correo electrónico ya está registrado.');
      } else if (response.statusCode == 422) {
        throw const RegisterException('El correo electrónico ya está en uso. Prueba con otro.');
      } else {
        throw RegisterException('Error del servidor (${response.statusCode}).');
      }
    } on RegisterException {
      rethrow;
    } on SocketException {
      throw const RegisterException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw RegisterException('Error inesperado: $e');
    }
  }
}