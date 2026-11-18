package br.com.poc.usuarios;

import java.net.URI;
import java.time.Instant;
import java.util.List;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/usuarios")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class UsuarioResource {

    @Inject
    UsuarioPublisher publisher;

    @POST
    @Transactional
    public Response criar(@Valid Usuario dados) {
        Instant agora = Instant.now();
        dados.criadoEm = agora;
        dados.atualizadoEm = agora;
        dados.persist();

        publisher.publicar(new UsuarioCriadoEvent(dados.id, dados.nome, dados.email, agora));

        return Response.created(URI.create("/usuarios/" + dados.id)).entity(dados).build();
    }

    @GET
    public List<Usuario> listar() {
        return Usuario.listAll();
    }

    @GET
    @Path("/{id}")
    public Response buscar(@PathParam("id") Long id) {
        Usuario u = Usuario.findById(id);
        return u == null ? Response.status(Response.Status.NOT_FOUND).build() : Response.ok(u).build();
    }

    @PUT
    @Path("/{id}")
    @Transactional
    public Response atualizar(@PathParam("id") Long id, @Valid Usuario dados) {
        Usuario u = Usuario.findById(id);
        if (u == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        u.nome = dados.nome;
        u.email = dados.email;
        u.atualizadoEm = Instant.now();
        return Response.ok(u).build();
    }
}
