import 'dart:convert';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/interface/pagos_interface.dart';
import 'package:app_mobile/core/models/pago_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class PagoService implements PagosInterface{

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
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Error al obtener los pagos: ${errorBody['message'] ?? 'Error desconocido'}',
        );
      }
    } catch (e) {
      throw Exception('Error al obtener los pagos: $e');
    }


  }
}