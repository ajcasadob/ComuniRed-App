import 'package:app_mobile/core/dtos/register_request_dto.dart';
import 'package:app_mobile/core/models/register_response.dart';
import 'package:app_mobile/core/service/register_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'register_page_event.dart';
part 'register_page_state.dart';

class RegisterPageBloc extends Bloc<RegisterPageEvent, RegisterPageState> {

  final RegisterService service;

  RegisterPageBloc(this.service) : super(RegisterPageInitial()) {
    on<RegisterUser>((event, emit) async {
      emit(RegisterPageLoading());
      try {
        final response = await service.register(event.requestDto);
        emit(RegisterPageSuccess(response));

      }catch (e) {
        emit(RegisterPageError(e.toString()));
      }
    
    });
  }
}
