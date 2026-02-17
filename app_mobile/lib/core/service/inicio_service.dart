import 'dart:convert';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/interface/inicio_interface.dart';
import 'package:app_mobile/core/models/inicio_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class InicioService implements InicioInterface{

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
        if(response.statusCode >=200 && response.statusCode <300){
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return InicioResponse.fromJson(responseBody);
    }else{
      final errorBody = jsonDecode(response.body);
      throw Exception("Error al obtener las estadísticas: ${errorBody['message'] ?? 'Error desconocido'}");
        }



    }catch(e){
      throw Exception("Error al obtener las estadísticas: $e");
    }


    
  }
}