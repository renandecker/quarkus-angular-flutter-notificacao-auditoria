package br.com.poc.notificacoes;

import java.time.Instant;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.smallrye.reactive.messaging.annotations.Blocking;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.reactive.messaging.Incoming;
import org.jboss.logging.Logger;

/** Worker assincrono: formata, "envia" e grava o historico. */
@ApplicationScoped
public class NotificacaoConsumer {

    private static final Logger LOG = Logger.getLogger(NotificacaoConsumer.class);

    @Inject
    ObjectMapper mapper;

    @Inject
    HistoricoService historico;

    @Inject
    TemplateService templates;

    @ConfigProperty(name = "notificacao.simular-delay-ms", defaultValue = "1200")
    long delayMs;

    @ConfigProperty(name = "notificacao.falha-keyword", defaultValue = "falha")
    String falhaKeyword;

    @Incoming("usuario-criado")
    @Blocking
    public void consumir(String json) {
        long inicio = System.currentTimeMillis();
        UsuarioCriadoEvent event;
        try {
            event = mapper.readValue(json, UsuarioCriadoEvent.class);
        } catch (Exception e) {
            LOG.errorf(e, "Mensagem invalida na fila, descartando: %s", json);
            return;
        }

        String email = event.email == null ? "" : event.email;
        String nome = event.nome == null ? "" : event.nome;
        String codigo = email.toLowerCase().contains("premium") ? "BOAS_VINDAS_PREMIUM" : "BOAS_VINDAS";
        Template template = templates.buscar(codigo);

        String assunto = template == null ? "Bem-vindo(a)!" : render(template.assunto, event);
        String corpo = template == null ? "Ola " + nome : render(template.corpo, event);

        boolean deveFalhar = email.toLowerCase().contains(falhaKeyword.toLowerCase());
        String status = deveFalhar ? "FALHA" : "ENVIADO";
        String detalhe = deveFalhar
                ? "SMTP simulado recusou o destinatario (palavra-chave '" + falhaKeyword + "')"
                : "Mensagem formatada e entregue ao servidor SMTP simulado";

        try {
            if (delayMs > 0) {
                Thread.sleep(delayMs);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }

        long duracao = System.currentTimeMillis() - inicio;
        LOG.infof("[%s] EMAIL SIMULADO | para=%s | assunto=%s | corpo=%s | template=%s | usuarioId=%s | %dms",
                  status, email, assunto, corpo, codigo, event.usuarioId, duracao);

        historico.registrar(event.usuarioId, email, nome, codigo, assunto, corpo,
                            status, detalhe, Instant.now(), duracao);
    }

    private String render(String texto, UsuarioCriadoEvent event) {
        return texto.replace("{nome}", event.nome == null ? "" : event.nome)
                    .replace("{email}", event.email == null ? "" : event.email)
                    .replace("{usuarioId}", String.valueOf(event.usuarioId));
    }
}
