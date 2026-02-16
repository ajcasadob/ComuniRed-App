import 'package:app_mobile/core/dtos/login_request_dto.dart';

abstract class LoginInterface {
  Future<String> login(LoginRequestDto request);
}