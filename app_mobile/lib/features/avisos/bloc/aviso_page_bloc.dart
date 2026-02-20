import 'package:app_mobile/core/models/avisos_response.dart';
import 'package:app_mobile/core/service/avisos_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'aviso_page_event.dart';
part 'aviso_page_state.dart';

class AvisoPageBloc extends Bloc<AvisoPageEvent, AvisoPageState> {

  final AvisosService _avisosService;

  AvisoPageBloc(this._avisosService) : super(AvisoPageInitial())  {
    on<AvisoPageEvent>((event, emit) async {
      emit(AvisoPageLoading());
      try {
        final List<AvisosResponse> avisos = await _avisosService.getAllAvisos();
        emit(AvisoPageLoaded(avisos));
      } catch (e) {
        emit(AvisoPageError(e.toString()));
      }
    });
  }
}
