# App mobile (Flutter)

Consome diretamente os três conjuntos de microsserviços. O seletor no topo alterna entre
**Quarkus 2** (8081/8082), **Quarkus 3** (8085/8086) e **Quarkus 4** (8083/8084);
o ícone de celular troca `localhost`
por `10.0.2.2` (host visto de dentro do emulador Android).

## Rodar

É necessário ter o Flutter SDK instalado (Dart >= 3.4). As pastas nativas (`android/`, `ios/`,
`web/`) não são versionadas aqui; gere-as uma vez:

```powershell
flutter create . --project-name notificacoes_app --platforms=android,ios,web
flutter pub get
flutter run                    # dispositivo/emulador conectado
flutter run -d chrome          # Flutter web (porta 4201: flutter run -d chrome --web-port 4201)
```

> No iOS Simulator, `localhost` funciona. No Android Emulator, toque no ícone do celular
> na AppBar para usar `10.0.2.2`. Em dispositivo físico,troque o host pelo IP da máquina
> que roda os serviços e libere as portas no firewall.

## Telas

- **Usuários**: formulário `POST /usuarios` + lista `GET /usuarios`. O SnackBar mostra o
  `X-Response-Time-ms` medido no cliente, provando que o cadastro não espera o SMTP.
- **Auditoria**: `GET /historico`, `GET /historico/resumo` com contadores `ENVIADO`/`FALHA`.

Dica: cadastre `algo.falha@email.com` para ver o status `FALHA`, ou `premium@email.com`
para usar o template `BOAS_VINDAS_PREMIUM`.
