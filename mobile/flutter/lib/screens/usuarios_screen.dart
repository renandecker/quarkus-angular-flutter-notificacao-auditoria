import 'package:flutter/material.dart';

import '../api_service.dart';
import '../config.dart';
import '../models.dart';

class UsuariosScreen extends StatefulWidget {
  final AppConfig config;
  final ApiService api;

  const UsuariosScreen({super.key, required this.config, required this.api});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();

  List<Usuario> _usuarios = [];
  String? _erro;
  String? _ultimoResultado;
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
    _nome.dispose();
    _email.dispose();
    super.dispose();
  }

  void _recarregar() => _carregar();

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final lista = await widget.api.listarUsuarios();
      if (mounted) setState(() => _usuarios = lista);
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _criar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      final r = await widget.api.criarUsuario(_nome.text.trim(), _email.text.trim());
      _form.currentState!.reset();
      _nome.clear();
      _email.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '201 Created em ${r.latencyMs} ms • id=${r.usuario.id}. '
            'A notificação está sendo processada pelo worker.',
          ),
        ),
      );
      setState(() => _ultimoResultado = 'Criado em ${r.latencyMs} ms');
      await _carregar();
    } catch (e) {
      if (mounted) setState(() => _erro = e.toString());
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nome,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        hintText: 'ana@email.com (use "falha" para simular erro)',
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Informe um e-mail válido'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _carregando ? null : _criar,
                      icon: const Icon(Icons.send),
                      label: Text(_carregando ? 'Aguarde...' : 'Cadastrar usuário'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_ultimoResultado != null)
            Chip(
              avatar: const Icon(Icons.speed, size: 16),
              label: Text(_ultimoResultado!),
            ),
          if (_erro != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _erro!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Usuários (${_usuarios.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              IconButton(onPressed: _carregar, icon: const Icon(Icons.refresh)),
            ],
          ),
          ..._usuarios.map(
            (u) => ListTile(
              leading: CircleAvatar(child: Text(u.nome.isEmpty ? '?' : u.nome[0])),
              title: Text(u.nome),
              subtitle: Text(u.email),
              trailing: Text('#${u.id}'),
            ),
          ),
        ],
      ),
    );
  }
}
