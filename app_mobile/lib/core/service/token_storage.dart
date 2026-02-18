import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {

  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';

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
}
