package br.com.poc.usuarios;

import java.util.concurrent.CompletionStage;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.eclipse.microprofile.reactive.messaging.Emitter;
import org.jboss.logging.Logger;

/** Quarkus 2: Emitter (API classica do MicroProfile Reactive Messaging). */
@ApplicationScoped
public class UsuarioPublisher {

    private static final Logger LOG = Logger.getLogger(UsuarioPublisher.class);

    @Inject
    @Channel("usuario-criado")
    Emitter<String> emitter;

    @Inject
    ObjectMapper mapper;

    public void publicar(UsuarioCriadoEvent event) {
        try {
            String json = mapper.writeValueAsString(event);
            CompletionStage<Void> enviado = emitter.send(json);
            enviado.toCompletableFuture().join();
            LOG.infof("Evento UsuarioCriado publicado: usuarioId=%s", event.usuarioId);
        } catch (Exception e) {
            // Nao desfaz o cadastro: o core nao pode depender do worker (Strangler Fig).
            LOG.errorf(e, "Falha ao publicar evento do usuario %s: %s", event.usuarioId, e.getMessage());
        }
    }
}
