import 'package:app_mobile/core/dtos/reserva_request_dto.dart';
import 'package:app_mobile/core/models/reserva_response.dart';
import 'package:app_mobile/core/service/reserva_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'reserva_page_event.dart';
part 'reserva_page_state.dart';

class ReservaPageBloc extends Bloc<ReservaPageEvent, ReservaPageState> {

  final ReservaService  service;
  ReservaPageBloc(this.service) : super(ReservaPageInitial()) {
    on<GetReservas>((event, emit) async{
    emit(ReservaPageLoading());
    try{
      final response = await service.getReservas();
      emit(ReservaPageLoaded(response));

    }catch(e){
      emit(ReservaPageError(e.toString()));
    }
});


    on<CrearReserva>((event, emit) async{
      emit(ReservaPageLoading());
      try{
        final response = await service.crearReserva(event.requestDto);
        emit(ReservaPageCreada(response));

      }catch(e){
        emit(ReservaPageError(e.toString()));
      }
    });

    on<UpdateReserva>((event, emit) async {
      emit(ReservaUpdating());
      try {
        final updated = await service.updateReserva(event.id, event.requestDto);
        emit(ReservaUpdated(updated));
      } catch (e) {
        emit(ReservaUpdateError(e.toString()));
      }
    });

    on<DeleteReserva>((event, emit) async {
      emit(ReservaDeleting());
      try {
        await service.deleteReserva(event.id);
        emit(ReservaDeleted());
      } catch (e) {
        emit(ReservaDeleteError(e.toString()));
      }
    });


  
  }
}
