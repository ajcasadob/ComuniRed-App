part of 'perfil_page_bloc.dart';

@immutable
sealed class PerfilPageEvent {}

final class GetPerfil extends PerfilPageEvent{}

final class UpdatePerfil extends PerfilPageEvent{
  final UpdateUsuarioRequest request;

  UpdatePerfil(this.request);
}
