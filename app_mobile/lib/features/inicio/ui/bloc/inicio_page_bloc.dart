import 'package:app_mobile/core/models/inicio_response.dart';
import 'package:app_mobile/core/service/inicio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'inicio_page_event.dart';
part 'inicio_page_state.dart';

class InicioPageBloc extends Bloc<InicioPageEvent, InicioPageState> {

final InicioService service;


  InicioPageBloc(this.service) : super(InicioPageInitial())  {
    on<GetAll>((event, emit)async {
   emit(InicioPageLoading());

   try{
    final response = await service.getAll();
    emit(InicioPageSuccess(response));
   }catch(e){
    emit(InicioPageError(e.toString()));
   }

    });
  }
}
