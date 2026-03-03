part of 'perfil_page_bloc.dart';

@immutable
sealed class PerfilPageState {}

final class PerfilPageInitial extends PerfilPageState {}
final class PerfilPageLoading extends PerfilPageState {}

final class PerfilPageLoaded extends PerfilPageState {
  final UsuarioResponse usuario;

  PerfilPageLoaded(this.usuario);
}

final class PerfilPageError extends PerfilPageState {
  final String message;

  PerfilPageError(this.message);
}


final class PerfilUpdating extends PerfilPageState {}

final class PerfilUpdated extends PerfilPageState {
  final UsuarioResponse usuario;

  PerfilUpdated(this.usuario);
}

final class PerfilUpdateError extends PerfilPageState {
  final String message;

  PerfilUpdateError(this.message);
}