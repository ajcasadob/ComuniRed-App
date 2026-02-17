part of 'inicio_page_bloc.dart';

@immutable
sealed class InicioPageState {}

final class InicioPageInitial extends InicioPageState {}

final class InicioPageLoading extends InicioPageState{}

final class InicioPageSuccess extends InicioPageState {
  final InicioResponse inicioResponse;
  InicioPageSuccess(this.inicioResponse);
}

final class InicioPageError extends InicioPageState{
  final String message;
  InicioPageError(this.message);
}