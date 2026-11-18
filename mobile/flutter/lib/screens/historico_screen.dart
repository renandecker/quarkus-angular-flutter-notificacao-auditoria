import 'package:flutter/material.dart';

import '../api_service.dart';
import '../config.dart';
import '../models.dart';

class HistoricoScreen extends StatefulWidget {
  final AppConfig config;
  final ApiService api;

  const HistoricoScreen({super.key, required this.config, required this.api});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  List<HistoricoEnvio> _itens = [];
  Resumo _resumo = Resumo(enviado: 0, falha: 0, total: 0);
  String? _erro;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    widget.config.addListener(_recarregar);
    _recarregar();
  }

  @override
  void dispose() {
    widget.config.removeListener(_recarregar);
    super.dispose();
  }

  void _recarregar() => _carregar();

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final resultados = await Future.wait([
        widget.api.listarHistorico(),
        widget.api.resumo(),
      ]);
      if (!mounted) return;
      setState(() {
        _itens = resultados[0] as List<HistoricoEnvio>;
        _resumo = resultados[1] as Resumo;
        _erro = null;
      });
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text('ENVIADO ${_resumo.enviado}'),
                avatar: Icon(Icons.check_circle, color: colors.primary, size: 18),
              ),
              Chip(
                label: Text('FALHA ${_resumo.falha}'),
                avatar: Icon(Icons.error, color: colors.error, size: 18),
              ),
              Chip(label: Text('TOTAL ${_resumo.total}')),
            ],
          ),
          if (_erro != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_erro!, style: TextStyle(color: colors.error)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Histórico de envios',
                  style: Theme.of(context).textTheme.titleMedium),
              IconButton(onPressed: _carregar, icon: const Icon(Icons.refresh)),
            ],
          ),
          if (_carregando)
            const LinearProgressIndicator()
          else if (_itens.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text('Nenhum envio registrado ainda.')),
            )
          else
            ..._itens.map(
              (h) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: h.sucesso ? colors.primaryContainer : colors.errorContainer,
                    child: Icon(
                      h.sucesso ? Icons.mail : Icons.report,
                      color: h.sucesso ? colors.primary : colors.error,
                    ),
                  ),
                  title: Text('${h.status} • ${h.email}'),
                  subtitle: Text(
                    'template=${h.templateCodigo} • usuarioId=${h.usuarioId} • '
                    'quarkus=${h.versaoQuarkus}\n${h.detalhe}',
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
