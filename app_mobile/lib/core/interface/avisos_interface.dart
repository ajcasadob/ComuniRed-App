import 'package:app_mobile/core/models/avisos_response.dart';

abstract class AvisosInterface {
  Future<List<AvisoResponse>> getAllAvisos();
}