import 'package:flutter/foundation.dart';

enum QuarkusVersion { q2, q3, q4 }

/// Configuracao global da PoC. Notifica a UI quando a versao/host muda.
class AppConfig extends ChangeNotifier {
  QuarkusVersion _version = QuarkusVersion.q2;
  bool _emulator = false;

  QuarkusVersion get version => _version;
  bool get emulator => _emulator;
  String get label => switch (_version) {
        QuarkusVersion.q2 => 'Quarkus 2',
        QuarkusVersion.q3 => 'Quarkus 3',
        QuarkusVersion.q4 => 'Quarkus 4',
      };

  String get host => _emulator ? '10.0.2.2' : 'localhost';

  int get _corePort => switch (_version) {
        QuarkusVersion.q2 => 8081,
        QuarkusVersion.q3 => 8085,
        QuarkusVersion.q4 => 8083,
      };

  int get _workerPort => switch (_version) {
        QuarkusVersion.q2 => 8082,
        QuarkusVersion.q3 => 8086,
        QuarkusVersion.q4 => 8084,
      };

  String get usuariosBase => 'http://$host:$_corePort';

  String get notificacoesBase => 'http://$host:$_workerPort';

  void setVersion(QuarkusVersion v) {
    if (_version != v) {
      _version = v;
      notifyListeners();
    }
  }

  void setEmulator(bool value) {
    if (_emulator != value) {
      _emulator = value;
      notifyListeners();
    }
  }
}
