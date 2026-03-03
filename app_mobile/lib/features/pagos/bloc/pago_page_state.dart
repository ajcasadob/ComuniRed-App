part of 'pago_page_bloc.dart';

@immutable
sealed class PagoPageState {}

final class PagoPageInitial extends PagoPageState {}
final class PagoPageLoading extends PagoPageState {}

final class PagoPageLoaded extends PagoPageState {
  final List<PagoResponse> pagos;

  PagoPageLoaded(this.pagos);
}

final class PagoPageError extends PagoPageState {
  final String message;

  PagoPageError(this.message);
}