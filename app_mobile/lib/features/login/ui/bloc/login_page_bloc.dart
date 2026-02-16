import 'package:app_mobile/core/dtos/login_request_dto.dart';
import 'package:app_mobile/core/models/login_response.dart';
import 'package:app_mobile/core/service/login_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'login_page_event.dart';
part 'login_page_state.dart';

class LoginPageBloc extends Bloc<LoginPageEvent, LoginPageState> {

  final LoginService service;

  LoginPageBloc(this.service) : super(LoginPageInitial()) {
    on<IniciarSesion>((event, emit) async {
      emit(LoginPageLoading());
      try{
        final response = await service.login(event.requestDto);
        emit(LoginPageSuccess(response));
      }catch(e){
        emit(LoginPageError(e.toString()));
      }

    });
  }
}
