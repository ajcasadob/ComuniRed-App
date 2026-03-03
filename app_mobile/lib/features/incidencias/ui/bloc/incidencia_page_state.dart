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

final class IncidenciaCreating extends IncidenciaPageState {}

final class IncidenciaCreated extends IncidenciaPageState {
  final IncidenciasResponse incidencia;

  IncidenciaCreated(this.incidencia);
}

final class IncidenciaCreateError extends IncidenciaPageState {
  final String message;

  IncidenciaCreateError(this.message);
}

final class IncidenciaUpdating extends IncidenciaPageState {}

final class IncidenciaUpdated extends IncidenciaPageState {
  final IncidenciasResponse incidencia;

  IncidenciaUpdated(this.incidencia);
}

final class IncidenciaUpdateError extends IncidenciaPageState {
  final String message;

  IncidenciaUpdateError(this.message);
}

final class IncidenciaDeleting extends IncidenciaPageState {}

final class IncidenciaDeleted extends IncidenciaPageState {}

final class IncidenciaDeleteError extends IncidenciaPageState {
  final String message;

  IncidenciaDeleteError(this.message);
}