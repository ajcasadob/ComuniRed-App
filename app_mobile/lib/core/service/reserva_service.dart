import 'dart:convert';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/reserva_request_dto.dart';
import 'package:app_mobile/core/interface/reserva_interface.dart';
import 'package:app_mobile/core/models/reserva_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class ReservaService implements ReservaInterface {

  final url = "${ApiConstants.baseUrl}/reservas";
  final TokenStorage _tokenStorage;
  ReservaService(this._tokenStorage);

  @override
  Future<List<ReservaResponse>> getReservas() async {

    try {

      final token = await _tokenStorage.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((e) => ReservaResponse.fromJson(e as Map<String, dynamic>))
            .toList();

      } else {

        final errorBody = jsonDecode(response.body);
        throw Exception(
          "Error al obtener las reservas: ${errorBody['message'] ?? 'Error desconocido'}",
        );
      }

    } catch (e) {
      throw Exception("Error al obtener las reservas: $e");
    }
  }

  @override
  Future<ReservaResponse> crearReserva(CrearReservaRequest request) async{

    try{

      final token = await _tokenStorage.getToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"

        },
        body: jsonEncode(request.toJson()));

        if(response.statusCode >= 200 && response.statusCode < 300){

          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          return ReservaResponse.fromJson(responseBody);

        }else{
          final errorBody= jsonDecode(response.body);
          throw Exception("Error al crear reserva: ${errorBody['message'] ?? 'Error desconocido'}");
        }
      
        
    
    }catch(e){
      throw Exception("Error al crear reserva: $e");
    }
  
  }
}
