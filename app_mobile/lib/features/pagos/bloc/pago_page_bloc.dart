import 'package:app_mobile/core/models/pago_response.dart';
import 'package:app_mobile/core/service/pago_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'pago_page_event.dart';
part 'pago_page_state.dart';

class PagoPageBloc extends Bloc<PagoPageEvent, PagoPageState> {
  final PagoService _pagoService;

  PagoPageBloc(this._pagoService) : super(PagoPageInitial()) {
    on<GetPagos>((event, emit) async {
      emit(PagoPageLoading());
      try {
        final List<PagoResponse> pagos = await _pagoService.getMisPagos();
        emit(PagoPageLoaded(pagos));
      } catch (e) {
        emit(PagoPageError(e.toString()));
      }
    });
  }
}
