import 'package:app_mobile/core/dtos/update_usuario_request.dart';
import 'package:app_mobile/core/models/usuario_response.dart';

abstract class PerfilInterface {
  Future<UsuarioResponse> getUsuario(int id);
  Future<UsuarioResponse> updateUsuario(int id, UpdateUsuarioRequest request);
  

}