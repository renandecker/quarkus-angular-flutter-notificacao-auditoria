package br.com.poc.usuarios;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.smallrye.reactive.messaging.MutinyEmitter;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.jboss.logging.Logger;

/** Quarkus 3: SmallRye RM 4.x com MutinyEmitter (Jackson 2). */
@ApplicationScoped
public class UsuarioPublisher {

    private static final Logger LOG = Logger.getLogger(UsuarioPublisher.class);

    @Inject
    @Channel("usuario-criado")
    MutinyEmitter<String> emitter;

    @Inject
    ObjectMapper mapper;

    public void publicar(UsuarioCriadoEvent event) {
        try {
            String json = mapper.writeValueAsString(event);
            emitter.sendAndAwait(json);
            LOG.infof("Evento UsuarioCriado publicado: usuarioId=%s", event.usuarioId);
        } catch (Exception e) {
            LOG.errorf(e, "Falha ao publicar evento do usuario %s: %s", event.usuarioId, e.getMessage());
        }
    }
}
