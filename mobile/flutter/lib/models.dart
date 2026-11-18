class Usuario {
  final int id;
  final String nome;
  final String email;
  final String? criadoEm;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.criadoEm,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['id'] as num).toInt(),
      nome: (json['nome'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      criadoEm: json['criadoEm']?.toString(),
    );
  }
}

class HistoricoEnvio {
  final int id;
  final int usuarioId;
  final String email;
  final String nome;
  final String templateCodigo;
  final String status;
  final String detalhe;
  final String versaoQuarkus;
  final String? criadoEm;

  HistoricoEnvio({
    required this.id,
    required this.usuarioId,
    required this.email,
    required this.nome,
    required this.templateCodigo,
    required this.status,
    required this.detalhe,
    required this.versaoQuarkus,
    this.criadoEm,
  });

  bool get sucesso => status == 'ENVIADO';

  factory HistoricoEnvio.fromJson(Map<String, dynamic> json) {
    return HistoricoEnvio(
      id: (json['id'] as num).toInt(),
      usuarioId: (json['usuarioId'] as num).toInt(),
      email: (json['email'] ?? '').toString(),
      nome: (json['nome'] ?? '').toString(),
      templateCodigo: (json['templateCodigo'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      detalhe: (json['detalhe'] ?? '').toString(),
      versaoQuarkus: (json['versaoQuarkus'] ?? '').toString(),
      criadoEm: json['criadoEm']?.toString(),
    );
  }
}

class Resumo {
  final int enviado;
  final int falha;
  final int total;

  Resumo({required this.enviado, required this.falha, required this.total});

  factory Resumo.fromJson(Map<String, dynamic> json) {
    return Resumo(
      enviado: (json['ENVIADO'] as num? ?? 0).toInt(),
      falha: (json['FALHA'] as num? ?? 0).toInt(),
      total: (json['TOTAL'] as num? ?? 0).toInt(),
    );
  }
}
