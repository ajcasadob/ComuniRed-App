import 'dart:convert';
import 'dart:io';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/interface/pagos_interface.dart';
import 'package:app_mobile/core/models/pago_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class PagoException implements Exception {
  final String message;
  const PagoException(this.message);

  @override
  String toString() => message;
}

class PagoService implements PagosInterface {

  final url = "${ApiConstants.baseUrl}/pagos";
  final TokenStorage _tokenStorage;

  PagoService(this._tokenStorage);



  @override
  Future<List<PagoResponse>> getMisPagos() async{
    try {
      final token = await _tokenStorage.getToken();

      final response = await http.get(
        Uri.parse('$url/mis-pagos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((e) => PagoResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw const PagoException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const PagoException('No tienes permiso para ver los pagos.');
      } else if (response.statusCode == 404) {
        throw const PagoException('Recurso no encontrado.');
      } else {
        throw PagoException('Error del servidor (${response.statusCode}).');
      }
    } on PagoException {
      rethrow;
    } on SocketException {
      throw const PagoException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw PagoException('Error inesperado: $e');
    }
  }
}