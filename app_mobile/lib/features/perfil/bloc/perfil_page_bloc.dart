import 'package:app_mobile/core/dtos/update_usuario_request.dart';
import 'package:app_mobile/core/models/usuario_response.dart';
import 'package:app_mobile/core/service/perfil_service.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'perfil_page_event.dart';
part 'perfil_page_state.dart';

class PerfilPageBloc extends Bloc<PerfilPageEvent, PerfilPageState> {

  final PerfilService _perfilService;
  final TokenStorage _tokenStorage;

  PerfilPageBloc(this._perfilService,this._tokenStorage) : super(PerfilPageInitial()) {
    on<GetPerfil>((event, emit) async {
      emit(PerfilPageLoading());
      try {
        final userId = await _tokenStorage.getUserId();
        if (userId == null) {
          emit(PerfilPageError('No se pudo obtener el usuario. Vuelve a iniciar sesión.'));
          return;
        }
        final usuario = await _perfilService.getUsuario(userId);
        emit(PerfilPageLoaded(usuario));
      } catch (e) {
        emit(PerfilPageError(e.toString()));
      }

    });

    on<UpdatePerfil>((event, emit) async {
      emit(PerfilUpdating());
      try {
        final userId = await _tokenStorage.getUserId();
        if (userId == null) {
          emit(PerfilUpdateError('No se pudo obtener el usuario. Vuelve a iniciar sesión.'));
          return;
        }
        final updated = await _perfilService.updateUsuario(userId, event.request);
        // Actualizamos el nombre en local si cambió
        await _tokenStorage.saveNombre(updated.name);
        emit(PerfilUpdated(updated));
      } catch (e) {
        emit(PerfilUpdateError(e.toString()));
      }
    });
  }
}
