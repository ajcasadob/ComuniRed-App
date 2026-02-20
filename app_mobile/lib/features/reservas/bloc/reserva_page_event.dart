part of 'reserva_page_bloc.dart';

@immutable
sealed class ReservaPageEvent {}

final class GetReservas extends ReservaPageEvent{}

final class CrearReserva extends ReservaPageEvent{

  final CrearReservaRequest requestDto;

  CrearReserva(this.requestDto);
}
