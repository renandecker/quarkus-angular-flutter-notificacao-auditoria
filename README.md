# PoC: Notificações e Auditoria de Usuários — Quarkus 2 vs 3 vs 4

Três implementações **independentes e completas** do mesmo desenho (Strangler Fig): **Quarkus 2.16.12.Final**, **Quarkus 3.40.1.2** e **Quarkus 4.0.0.CR1**. Cada versão tem os dois serviços, o broker e os bancos isolados — dá para rodar as três ao mesmo tempo e comparar.

```
                          ┌──────────────────────────┐
  POST /usuarios  ───────► │ Usuários (core/síncrono) │  :8081 (Q2) / :8085 (Q3) / :8083 (Q4)
                          └────────────┬─────────────┘
                                       │ evento UsuarioCriado (JSON)
                                       ▼
                          ┌──────────────────────────┐
                          │ RabbitMQ (topic exchange)│  notificacoes.q2 / .q3 / .q4
                          └────────────┬─────────────┘
                                       ▼
                          ┌──────────────────────────┐
                          │ Notificações (worker)    │  :8082 (Q2) / :8086 (Q3) / :8084 (Q4)
                          │ template + histórico     │
                          └──────────────────────────┘
```

O `POST /usuarios` grava no Postgres, publica o evento e responde **201** sem esperar o "SMTP" (que dorme ~1,2 s de propósito). O worker consome, escolhe o template, simula o envio e grava `ENVIADO` ou `FALHA`.

## Estrutura

```
├── docker-compose.yml            RabbitMQ + Postgres
├── infra/postgres/init.sql       cria 6 databases (um por serviço/versão)
├── scripts/
│   ├── build-all.ps1             build dos 6 módulos
│   ├── run-q2.ps1 / run-q3.ps1 / run-q4.ps1   atalhos para quarkus:dev
│   └── smoke-test.ps1            POST + consulta do histórico
├── quarkus2/
│   ├── usuarios-service/         :8081
│   └── notificacoes-service/     :8082
├── quarkus3/
│   ├── usuarios-service/         :8085
│   └── notificacoes-service/     :8086
├── quarkus4/
│   ├── usuarios-service/         :8083
│   └── notificacoes-service/     :8084
├── web/angular/                  app web Angular (porta 4200)
└── mobile/flutter/               app mobile Flutter (Android/iOS/Web)
```

## Pré-requisitos

- JDK 21 (Q3 e Q4 exigem 17+; o Q2 compila para 11 e roda no 21 com override do ByteBuddy já configurado no POM)
- Maven 3.9+
- Docker + Docker Compose

> As portas publicadas são **55432** (Postgres), **55672** (AMQP) e **15673** (management) para não colidir com instalações locais que já usem 5432/5672/15672. Se quiser as portas padrão, troque no `docker-compose.yml` e nos `application.properties`.

## Subindo

```powershell
docker compose up -d
.\scripts\build-all.ps1

# terminais separados (dev mode, hot reload):
cd quarkus2\usuarios-service;    mvn quarkus:dev   # 8081
cd quarkus2\notificacoes-service;mvn quarkus:dev   # 8082
cd quarkus3\usuarios-service;    mvn quarkus:dev   # 8085
cd quarkus3\notificacoes-service;mvn quarkus:dev   # 8086
cd quarkus4\usuarios-service;    mvn quarkus:dev   # 8083
cd quarkus4\notificacoes-service;mvn quarkus:dev   # 8084
```

Para rodar os jars já buildados:

```powershell
java -jar quarkus2\usuarios-service\target\quarkus-app\quarkus-run.jar
java -jar quarkus3\usuarios-service\target\quarkus-app\quarkus-run.jar
java -jar quarkus4\usuarios-service\target\quarkus-app\quarkus-run.jar
```

> Se o Postgres já estava rodando antes de o `init.sql` ganhar os bancos `*_q3`, crie-os uma vez:
> `docker exec poc-postgres psql -U postgres -c 'CREATE DATABASE usuarios_q3'`
> e `docker exec poc-postgres psql -U postgres -c 'CREATE DATABASE notificacoes_q3'`.

Health check: `http://localhost:8081/q/health` (troque a porta). RabbitMQ UI: `http://localhost:15673` (guest/guest).

## Frontends

As duas aplicações consomem os mesmos serviços e alternam entre **Q2** (8081/8082), **Q3** (8085/8086) e **Q4** (8083/8084).
O CORS já está habilitado nos seis serviços para `localhost:4200` e `localhost:4201`.

```powershell
# Web — Angular 21 (Node >= 22.12)
cd web\angular
npm install          # já executado na PoC
npm start            # http://localhost:4200
# npm run build      # bundle de produção em dist/usuarios-app

# Mobile — Flutter (SDK não instalado nesta máquina; Dart >= 3.4)
cd mobile\flutter
flutter create . --project-name notificacoes_app --platforms=android,ios,web
flutter pub get
flutter run -d chrome --web-port 4201   # Flutter web
flutter run                             # emulador/dispositivo
```

No Angular, o seletor no topo troca a versão, o formulário mede a latência do `POST` e o painel
direito mostra o histórico/resumo do worker correspondente. No Flutter, o mesmo seletor fica na
AppBar; o ícone de celular troca `localhost` por `10.0.2.2` para o emulador Android.
Veja `mobile/flutter/README.md` para detalhes de host/emulador.

## Endpoints

### Serviço de Usuários

| Método | Rota | Descrição |
|---|---|---|
| `POST` | `/usuarios` | cria `{ "nome": "Ana", "email": "ana@email.com" }`, publica o evento e retorna 201 + header `X-Response-Time-ms` |
| `GET` | `/usuarios` | lista usuários |
| `GET` | `/usuarios/{id}` | busca por id |
| `PUT` | `/usuarios/{id}` | atualiza nome/e-mail |

### Serviço de Notificações

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/templates` | templates boas-vindas (inclusive variante Premium) |
| `GET` | `/historico` | últimos 50 envios |
| `GET` | `/historico/usuario/{id}` | envios de um usuário |
| `GET` | `/historico/status/{status}` | `ENVIADO` ou `FALHA` |
| `GET` | `/historico/resumo` | contadores por status |

## Experimentos

### 1. Latência

```powershell
.\scripts\smoke-test.ps1 -Port 8081   # Quarkus 2
.\scripts\smoke-test.ps1 -Port 8085   # Quarkus 3
.\scripts\smoke-test.ps1 -Port 8083   # Quarkus 4
```

O header `X-Response-Time-ms` do POST fica na casa de dezenas de milissegundos, enquanto o log do worker mostra ~1200 ms de "SMTP". Se o envio fosse síncrono, o cliente pagaria esse tempo.

### 2. Tolerância a falhas

1. Pare o worker (Ctrl+C no terminal de `notificacoes-service`).
2. Faça 5 POSTs no serviço de usuários.
3. Veja as mensagens acumuladas na fila `notificacao.usuario.criado.q2` (ou `.q3` / `.q4`) no management do RabbitMQ.
4. Suba o worker de novo: ele drena a fila e grava os 5 envios, sem perda. Filas e exchanges são duráveis; mensagens são confirmadas só depois do processamento.

### 3. Falha de envio

Use um e-mail contendo `falha` (ex.: `joao.falha@email.com`). O worker grava `FALHA` com o detalhe e o evento é confirmado — sem loop de retry infinito. E-mails com `premium` usam o template `BOAS_VINDAS_PREMIUM`.

### 4. Escalabilidade independente

Suba mais réplicas **apenas do worker** apontando para a mesma fila:

```powershell
# outra instância Q2, sem tocar no serviço de usuários
mvn quarkus:dev -Dquarkus.http.port=8087
```

O RabbitMQ distribui as mensagens entre os consumidores. As mensagens com chave de roteamento `usuario.criado` chegam a uma versão apenas se o exchange correspondente (`q2`, `q3` ou `q4`) for o mesmo — aqui cada versão tem o seu, então não há interferência.

## O que muda entre Q2, Q3 e Q4

| Item | Quarkus 2 | Quarkus 3 | Quarkus 4 |
|---|---|---|---|
| BOM | `2.16.12.Final` | `3.40.1.2` | `4.0.0.CR1` |
| Java | release 11 (override ByteBuddy 1.14.19 para JDK 21) | release 17 | release 17 |
| REST | `quarkus-resteasy-reactive` | `quarkus-rest` | `quarkus-rest` |
| JSON | Jackson 2 (`com.fasterxml.jackson...`) | Jackson 2 (`com.fasterxml.jackson...`) | Jackson 3 (`tools.jackson...`) — **mudança de pacote** |
| RabbitMQ | `quarkus-smallrye-reactive-messaging-rabbitmq` (SmallRye 3.x) | `quarkus-messaging-rabbitmq` (SmallRye 4.x) | `quarkus-messaging-rabbitmq` (SmallRye 5.x) |
| Publicação | `Emitter<String>` + `CompletionStage` | `MutinyEmitter<String>` + `sendAndAwait` | `MutinyEmitter<String>` + `sendAndAwait` |
| Anotações | `javax.*` | `jakarta.*` | `jakarta.*` |
| Schema do Hibernate | `quarkus.hibernate-orm.database.generation` | `quarkus.hibernate-orm.schema-management.strategy` | `quarkus.hibernate-orm.schema-management.strategy` |

O contrato do evento (`usuarioId`, `nome`, `email`, `ocorridoEm`) e o JSON trafegado são idênticos nas três versões; a lógica de negócio do worker também.
