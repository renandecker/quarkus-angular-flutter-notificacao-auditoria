import 'package:flutter/material.dart';

import 'api_service.dart';
import 'config.dart';
import 'screens/historico_screen.dart';
import 'screens/usuarios_screen.dart';

class ApiApp extends StatelessWidget {
  final AppConfig config;

  const ApiApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: config,
      builder: (context, _) {
        final api = ApiService(config);
        return MaterialApp(
          title: 'Notificações • PoC',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
          ),
          home: HomeShell(config: config, api: api),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  final AppConfig config;
  final ApiService api;

  const HomeShell({super.key, required this.config, required this.api});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notificações & Auditoria', style: TextStyle(fontSize: 17)),
            Text(
              '${cfg.label} • core ${cfg.usuariosBase} • worker ${cfg.notificacoesBase}',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          DropdownButton<QuarkusVersion>(
            value: cfg.version,
            underline: const SizedBox.shrink(),
            onChanged: (v) {
              if (v != null) cfg.setVersion(v);
            },
            items: const [
              DropdownMenuItem(value: QuarkusVersion.q2, child: Text('Q2')),
              DropdownMenuItem(value: QuarkusVersion.q3, child: Text('Q3')),
              DropdownMenuItem(value: QuarkusVersion.q4, child: Text('Q4')),
            ],
          ),
          IconButton(
            tooltip: 'Usar host do emulador Android (10.0.2.2)',
            icon: Icon(
              Icons.smartphone,
              color: cfg.emulator ? Colors.indigo : null,
            ),
            onPressed: () => cfg.setEmulator(!cfg.emulator),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          UsuariosScreen(config: cfg, api: widget.api),
          HistoricoScreen(config: cfg, api: widget.api),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_add), label: 'Usuários'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Auditoria'),
        ],
      ),
    );
  }
}
