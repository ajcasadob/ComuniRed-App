import 'package:app_mobile/core/dtos/register_request_dto.dart';
import 'package:app_mobile/core/models/register_response.dart';

abstract class RegisterInterface {
  Future<RegisterResponse> register(RegisterRequestDto request);
}