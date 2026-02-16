import 'dart:convert';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/login_request_dto.dart';
import 'package:app_mobile/core/interface/login_interface.dart';
import 'package:app_mobile/core/models/login_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class LoginService  implements LoginInterface {


  final TokenStorage _tokenStorage;
    LoginService(this._tokenStorage);


    @override
  Future<LoginResponse> login(LoginRequestDto request)async {


try{
    final url = "${ApiConstants.baseUrl}/login";
    

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json",
        "Accept": "application/json"},
        body:jsonEncode(request.toJson())

        );

  

    if(response.statusCode >=200 && response.statusCode <300){
      
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      final loginResponse = LoginResponse.fromJson(responseBody);
        await _tokenStorage.saveToken(loginResponse.token);
      return loginResponse;
    }else{
      final errorBody = jsonDecode(response.body);
      throw Exception("Error al iniciar sesión: ${errorBody['message'] ?? 'Error desconocido'}");
    }


  }catch(e){
    throw Exception("Error al iniciar sesión: $e");


    
  }
  }
}