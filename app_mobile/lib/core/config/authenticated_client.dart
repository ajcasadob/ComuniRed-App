import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class AuthenticatedClient extends http.BaseClient {

  final http.Client _inner = http.Client();
  final TokenStorage _tokenStorage;

  AuthenticatedClient(this._tokenStorage);


  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async{

    final token = await _tokenStorage.getToken();

    if (token != null) {
      request.headers['Authorization'] = 'Barer $token';
    }

      return _inner.send(request);
  }
}