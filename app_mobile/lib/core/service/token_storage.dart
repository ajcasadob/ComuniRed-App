import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {

  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _viviendaIdKey = 'vivienda_id';
  static const String _nombreKey = 'nombre';

  final FlutterSecureStorage _secureStorage;
  const TokenStorage(this._secureStorage);

  //  Token 

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  //  UserId 

  Future<void> saveUserId(int userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId.toString());
  }

  Future<int?> getUserId() async {
    final value = await _secureStorage.read(key: _userIdKey);
    return value != null ? int.parse(value) : null;
  }

  Future<void> deleteUserId() async {
    await _secureStorage.delete(key: _userIdKey);
  }


Future<void> saveViviendaId(int? viviendaId) async {
  if (viviendaId != null) {
    await _secureStorage.write(key: _viviendaIdKey, value: viviendaId.toString());
  }
}

Future<int?> getViviendaId() async {
  final value = await _secureStorage.read(key: _viviendaIdKey);
  return value != null ? int.tryParse(value) : null;
}

Future<void> deleteViviendaId() async {
  await _secureStorage.delete(key: _viviendaIdKey);
}

Future<void> saveNombre(String nombre) async {
  await _secureStorage.write(key: _nombreKey, value: nombre);
}

Future<String?> getNombre() async {
  return await _secureStorage.read(key: _nombreKey);
}

}
