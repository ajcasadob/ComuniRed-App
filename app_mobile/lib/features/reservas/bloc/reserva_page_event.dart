part of 'reserva_page_bloc.dart';

@immutable
sealed class ReservaPageEvent {}

final class GetReservas extends ReservaPageEvent{}

final class CrearReserva extends ReservaPageEvent{

  final CrearReservaRequest requestDto;

  CrearReserva(this.requestDto);
}

final class UpdateReserva extends ReservaPageEvent{

  final int id;
  final CrearReservaRequest requestDto;

  UpdateReserva(this.id, this.requestDto);
}

final class DeleteReserva extends ReservaPageEvent{

  final int id;

  DeleteReserva(this.id);
}
