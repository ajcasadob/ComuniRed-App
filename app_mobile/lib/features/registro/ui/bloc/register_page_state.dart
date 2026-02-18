part of 'register_page_bloc.dart';

@immutable
sealed class RegisterPageState {}

final class RegisterPageInitial extends RegisterPageState {}

final class RegisterPageLoading extends RegisterPageState{}

final class RegisterPageSuccess extends RegisterPageState{
  final RegisterResponse registerResponse;
  RegisterPageSuccess(this.registerResponse);
}


final class RegisterPageError extends RegisterPageState{
  final String message;
  RegisterPageError(this.message);
}
