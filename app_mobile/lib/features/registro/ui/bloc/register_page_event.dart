part of 'register_page_bloc.dart';

@immutable
sealed class RegisterPageEvent {}

final class RegisterUser extends RegisterPageEvent{
  final RegisterRequestDto requestDto;
  RegisterUser(this.requestDto);
}
