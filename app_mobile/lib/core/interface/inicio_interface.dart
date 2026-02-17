import 'package:app_mobile/core/models/inicio_response.dart';

abstract class InicioInterface {
  Future<InicioResponse> getAll();
}