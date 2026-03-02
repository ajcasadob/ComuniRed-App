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
        "Authorization": "Bearer $token"
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        return responseBody
            .map((e) => IncidenciasResponse.fromJson(e))
            .toList();
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
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return IncidenciasResponse.fromJson(responseBody);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(
          "Error al crear la incidencia: ${errorBody['message'] ?? 'Error desconocido'}");
    }
  } catch (e) {
    throw Exception("Error al crear la incidencia: $e");
  }





  }


}
