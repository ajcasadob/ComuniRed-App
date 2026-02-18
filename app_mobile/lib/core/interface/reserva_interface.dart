import 'package:app_mobile/core/dtos/reserva_request_dto.dart';
import 'package:app_mobile/core/models/reserva_response.dart';

abstract class ReservaInterface {
  Future<List<ReservaResponse>> getReservas();
  Future<ReservaResponse> crearReserva(CrearReservaRequest request);
}