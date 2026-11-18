package br.com.poc.usuarios;

import java.net.URI;
import java.time.Instant;
import java.util.List;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.validation.Valid;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

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

        // Side-effect publicado DEPOIS do commit logico do cadastro, sem esperar o envio.
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
