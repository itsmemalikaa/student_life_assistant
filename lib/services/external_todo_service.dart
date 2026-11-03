import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/external_todo.dart';

/// Exception dengan pesan yang siap ditampilkan ke pengguna.
class ExternalTodoException implements Exception {
  const ExternalTodoException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Service layer: satu-satunya tempat yang tahu endpoint, HTTP request,
/// status code, decoding JSON, dan mapping ke model.
/// Service TIDAK menampilkan pesan ke pengguna — UI yang menentukan.
class ExternalTodoService {
  ExternalTodoService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _host = 'jsonplaceholder.typicode.com';
  static const _todosPath = '/todos';
  static const _wrongPath = '/endpoint-tidak-ada'; // untuk uji kondisi gagal

  /// Alur: URI -> GET -> cek STATUS -> DECODE -> MAP -> RETURN
  Future<List<ExternalTodo>> fetchTodos({bool simulateFailure = false}) async {
    // 1. URI
    final uri = Uri.https(_host, simulateFailure ? _wrongPath : _todosPath);

    // 2. GET
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ExternalTodoException(
        'Koneksi terlalu lama. Periksa internet lalu coba lagi.',
      );
    } on http.ClientException {
      throw const ExternalTodoException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    }

    // 3. STATUS
    if (response.statusCode != 200) {
      throw ExternalTodoException(
        'Gagal mengambil data (HTTP ${response.statusCode}).',
      );
    }

    // 4. DECODE
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ExternalTodoException(
        'Format data tidak sesuai dengan yang diharapkan.',
      );
    }

    // 5. MAP  6. RETURN
    return decoded
        .take(15)
        .map((item) => ExternalTodo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  void dispose() {
    _client.close();
  }
}
