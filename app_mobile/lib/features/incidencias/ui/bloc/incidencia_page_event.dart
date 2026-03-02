part of 'incidencia_page_bloc.dart';

@immutable
sealed class IncidenciaPageEvent {}

final class GetIncidencias extends IncidenciaPageEvent {}

final class CreateIncidencia extends IncidenciaPageEvent {
  final IncidenciaRequest request;
  CreateIncidencia(this.request);
}
