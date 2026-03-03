part of 'incidencia_page_bloc.dart';

@immutable
sealed class IncidenciaPageEvent {}

final class GetIncidencias extends IncidenciaPageEvent {}

final class CreateIncidencia extends IncidenciaPageEvent {
  final IncidenciaRequest request;
  CreateIncidencia(this.request);
}

class UpdateIncidencia extends IncidenciaPageEvent {
  final int id;
  final IncidenciaRequest request;

  UpdateIncidencia(this.id,this.request); 
}


final class DeleteIncidencia extends IncidenciaPageEvent {
  final int id;
  DeleteIncidencia(this.id);
}
