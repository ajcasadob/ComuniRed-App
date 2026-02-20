part of 'reserva_page_bloc.dart';

@immutable
sealed class ReservaPageState {}

final class ReservaPageInitial extends ReservaPageState {}

final class ReservaPageLoading extends ReservaPageState {}

final class ReservaPageLoaded extends ReservaPageState {
  final List<ReservaResponse> reservas;

  ReservaPageLoaded(this.reservas);
}

final class ReservaPageCreada extends ReservaPageState {
  final ReservaResponse reserva;

  ReservaPageCreada(this.reserva);
}

final class ReservaPageError extends ReservaPageState {
  final String message;

  ReservaPageError(this.message);
}