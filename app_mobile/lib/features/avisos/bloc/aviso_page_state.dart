part of 'aviso_page_bloc.dart';

@immutable
sealed class AvisoPageState {}

final class AvisoPageInitial extends AvisoPageState {}

final class AvisoPageLoading extends AvisoPageState {}

final class AvisoPageLoaded extends AvisoPageState {
  final List<AvisosResponse> avisos;

  AvisoPageLoaded(this.avisos);
}

final class AvisoPageError extends AvisoPageState {
  final String message;

  AvisoPageError(this.message);
}


