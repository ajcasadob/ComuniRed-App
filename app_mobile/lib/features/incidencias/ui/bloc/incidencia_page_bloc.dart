import 'package:app_mobile/core/dtos/incidencia_request.dart';
import 'package:app_mobile/core/models/incidencias_response.dart';
import 'package:app_mobile/core/service/incidencias_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'incidencia_page_event.dart';
part 'incidencia_page_state.dart';

class IncidenciaPageBloc extends Bloc<IncidenciaPageEvent, IncidenciaPageState> {
final IncidenciasService _incidenciasService;

  IncidenciaPageBloc(this._incidenciasService) : super(IncidenciaPageInitial()) {

    on<GetIncidencias>((event, emit) async {
      emit(IncidenciaPageLoading());
      try {
        final List<IncidenciasResponse>  incidencias = await _incidenciasService.getAllIncidencias();
        emit(IncidenciaPageLoaded(incidencias));
      } catch (e) {
        emit(IncidenciaPageError(e.toString()));
      }
    });


    on<CreateIncidencia>((event, emit) async {
      emit(IncidenciaCreating());
      try {
        final created =
            await _incidenciasService.createIncidencia(event.request);
        emit(IncidenciaCreated(created));
      } catch (e) {
        emit(IncidenciaCreateError(e.toString()));
      }
    });
  }
}
