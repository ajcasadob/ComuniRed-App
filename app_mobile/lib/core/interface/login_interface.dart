import 'package:app_mobile/core/dtos/login_request_dto.dart';
import 'package:app_mobile/core/models/login_response.dart';

abstract class LoginInterface {
  Future<LoginResponse> login(LoginRequestDto request);
}