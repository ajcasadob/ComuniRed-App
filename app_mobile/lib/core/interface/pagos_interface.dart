import 'package:app_mobile/core/models/pago_response.dart';

abstract class PagosInterface {
  Future<List<PagoResponse>> getMisPagos();
}