import 'dart:convert';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/update_usuario_request.dart';
import 'package:app_mobile/core/interface/perfil_interface.dart';
import 'package:app_mobile/core/models/usuario_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

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
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Error al obtener el usuario: ${errorBody['message'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error al obtener el usuario: $e');
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
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
            'Error al actualizar el usuario: ${errorBody['message'] ?? 'Error desconocido'}');
      }
    } catch (e) {
      throw Exception('Error al actualizar el usuario: $e');
    }

  }
}