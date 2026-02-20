part of 'incidencia_page_bloc.dart';

@immutable
sealed class IncidenciaPageState {}

final class IncidenciaPageInitial extends IncidenciaPageState {}

final class IncidenciaPageLoading extends IncidenciaPageState {}

final class IncidenciaPageLoaded extends IncidenciaPageState {
  final List<IncidenciasResponse> incidencias;

  IncidenciaPageLoaded(this.incidencias);
}

final class IncidenciaPageError extends IncidenciaPageState {
  final String message;

  IncidenciaPageError(this.message);
}