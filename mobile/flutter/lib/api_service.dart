import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  final AppConfig config;
  final http.Client _client = http.Client();

  ApiService(this.config);

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<({Usuario usuario, int latencyMs})> criarUsuario(
    String nome,
    String email,
  ) async {
    final uri = Uri.parse('${config.usuariosBase}/usuarios');
    final sw = Stopwatch()..start();
    final response = await _client
        .post(uri, headers: _headers, body: jsonEncode({'nome': nome, 'email': email}))
        .timeout(const Duration(seconds: 10));
    sw.stop();

    if (response.statusCode != 201) {
      throw ApiException('POST falhou (${response.statusCode}): ${response.body}');
    }
    return (
      usuario: Usuario.fromJson(jsonDecode(response.body) as Map<String, dynamic>),
      latencyMs: sw.elapsedMilliseconds,
    );
  }

  Future<List<Usuario>> listarUsuarios() async {
    final uri = Uri.parse('${config.usuariosBase}/usuarios');
    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw ApiException('GET usuarios falhou (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  Future<List<HistoricoEnvio>> listarHistorico() async {
    final uri = Uri.parse('${config.notificacoesBase}/historico');
    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw ApiException('GET historico falhou (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => HistoricoEnvio.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Resumo> resumo() async {
    final uri = Uri.parse('${config.notificacoesBase}/historico/resumo');
    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw ApiException('GET resumo falhou (${response.statusCode})');
    }
    return Resumo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
