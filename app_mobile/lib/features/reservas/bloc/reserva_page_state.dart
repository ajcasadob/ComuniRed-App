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

final class ReservaUpdating extends ReservaPageState {}

final class ReservaUpdated extends ReservaPageState {
  final ReservaResponse reserva;

  ReservaUpdated(this.reserva);
}

final class ReservaUpdateError extends ReservaPageState {
  final String message;

  ReservaUpdateError(this.message);
}

final class ReservaDeleting extends ReservaPageState {}

final class ReservaDeleted extends ReservaPageState {}

final class ReservaDeleteError extends ReservaPageState {
  final String message;

  ReservaDeleteError(this.message);
}