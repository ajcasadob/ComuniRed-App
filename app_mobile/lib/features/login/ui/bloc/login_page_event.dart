part of 'login_page_bloc.dart';

@immutable
sealed class LoginPageEvent {}

final class IniciarSesion extends LoginPageEvent{
  final LoginRequestDto requestDto;
  IniciarSesion(this.requestDto);
}
