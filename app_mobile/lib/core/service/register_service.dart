import 'dart:convert';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/register_request_dto.dart';
import 'package:app_mobile/core/interface/register_interface.dart';
import 'package:app_mobile/core/models/register_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class RegisterService implements RegisterInterface {

  final TokenStorage _tokenStorage;
  RegisterService(this._tokenStorage);

  @override
  Future<RegisterResponse> register(RegisterRequestDto request) async {

    try{
      final url = "${ApiConstants.baseUrl}/register";

      var response = await http.post(Uri.parse(url),
      headers:{
        "Content-Type":"application/json",
        "Accept":"application/json"
      },
      body: jsonEncode(request.toJson())
        

      );

      if(response.statusCode >=200 && response.statusCode <300){
        final Map<String,dynamic> responseBody = jsonDecode(response.body);
        final registerResponse = RegisterResponse.fromJson(responseBody);
        await _tokenStorage.saveToken(registerResponse.token);
        return registerResponse;
      }else{
        final errorBody = jsonDecode(response.body);
        throw Exception("Error al registrarse: ${errorBody['message'] ?? 'Error desconocido'}");
      }




    }catch(e){
      throw Exception("Error al registrarse: $e");
    }

  }
}