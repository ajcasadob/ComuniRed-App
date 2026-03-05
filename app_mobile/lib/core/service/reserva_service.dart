import 'dart:convert';
import 'dart:io';

import 'package:app_mobile/core/config/api_constants.dart';
import 'package:app_mobile/core/dtos/reserva_request_dto.dart';
import 'package:app_mobile/core/interface/reserva_interface.dart';
import 'package:app_mobile/core/models/reserva_response.dart';
import 'package:app_mobile/core/service/token_storage.dart';
import 'package:http/http.dart' as http;

class ReservaException implements Exception {
  final String message;
  const ReservaException(this.message);

  @override
  String toString() => message;
}

class ReservaService implements ReservaInterface {

  final url = "${ApiConstants.baseUrl}/reservas";
  final TokenStorage _tokenStorage;
  ReservaService(this._tokenStorage);

  @override
  Future<List<ReservaResponse>> getReservas() async {

    try {

      final token = await _tokenStorage.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((e) => ReservaResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw const ReservaException('No autorizado. Por favor, inicia sesión.');
      } else if (response.statusCode == 403) {
        throw const ReservaException('No tienes permiso para ver las reservas.');
      } else if (response.statusCode == 404) {
        throw const ReservaException('Recurso no encontrado.');
      } else {
        throw ReservaException('Error del servidor (${response.statusCode}).');
      }
    } on ReservaException {
      rethrow;
    } on SocketException {
      throw const ReservaException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw ReservaException('Error inesperado: $e');
    }
  }

  @override
  Future<ReservaResponse> crearReserva(CrearReservaRequest request) async{

    try{

      final token = await _tokenStorage.getToken();
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token"

        },
        body: jsonEncode(request.toJson()));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          return ReservaResponse.fromJson(responseBody);
        } else if (response.statusCode == 400) {
          throw const ReservaException('Datos de la reserva inválidos.');
        } else if (response.statusCode == 401) {
          throw const ReservaException('No autorizado. Por favor, inicia sesión.');
        } else if (response.statusCode == 403) {
          throw const ReservaException('No tienes permiso para crear reservas.');
        } else if (response.statusCode == 409) {
          throw const ReservaException('Ya existe una reserva en ese horario.');
        } else if (response.statusCode == 422) {
          throw const ReservaException('Horario inválido. La hora de fin debe ser posterior a la hora de inicio.');
        } else {
          throw ReservaException('Error del servidor (${response.statusCode}).');
        }
    } on ReservaException {
      rethrow;
    } on SocketException {
      throw const ReservaException('No se pudo conectar al servidor. Verifica tu conexión.');
    } catch (e) {
      throw ReservaException('Error inesperado: $e');
    }
  }
  
  @override
  Future<void> deleteReserva(int id)async {
   try {
    final token = await _tokenStorage.getToken();
    final response = await http.delete(
      Uri.parse("$url/$id"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else if (response.statusCode == 401) {
      throw const ReservaException('No autorizado. Por favor, inicia sesión.');
    } else if (response.statusCode == 403) {
      throw const ReservaException('No tienes permiso para eliminar esta reserva.');
    } else if (response.statusCode == 404) {
      throw const ReservaException('Reserva no encontrada.');
    } else {
      throw ReservaException('Error del servidor (${response.statusCode}).');
    }
  } on ReservaException {
    rethrow;
  } on SocketException {
    throw const ReservaException('No se pudo conectar al servidor. Verifica tu conexión.');
  } catch (e) {
    throw ReservaException('Error inesperado: $e');
  }
  }
  
  @override
  Future<ReservaResponse> updateReserva(int id, CrearReservaRequest request) async {
   try {
    final token = await _tokenStorage.getToken();
    final response = await http.put(
      Uri.parse("$url/$id"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ReservaResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      throw const ReservaException('Datos de la reserva inválidos.');
    } else if (response.statusCode == 401) {
      throw const ReservaException('No autorizado. Por favor, inicia sesión.');
    } else if (response.statusCode == 403) {
      throw const ReservaException('No tienes permiso para modificar esta reserva.');
    } else if (response.statusCode == 404) {
      throw const ReservaException('Reserva no encontrada.');
    } else {
      throw ReservaException('Error del servidor (${response.statusCode}).');
    }
  } on ReservaException {
    rethrow;
  } on SocketException {
    throw const ReservaException('No se pudo conectar al servidor. Verifica tu conexión.');
  } catch (e) {
    throw ReservaException('Error inesperado: $e');
  }

  }
}
