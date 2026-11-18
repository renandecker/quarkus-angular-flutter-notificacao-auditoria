package br.com.poc.notificacoes;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/")
@Produces(MediaType.APPLICATION_JSON)
public class NotificacaoResource {

    @GET
    @Path("templates")
    public List<Template> templates() {
        return Template.listAll();
    }

    @GET
    @Path("historico")
    public List<HistoricoEnvio> historico() {
        return HistoricoEnvio.find("order by id desc").page(0, 50).list();
    }

    @GET
    @Path("historico/usuario/{id}")
    public List<HistoricoEnvio> porUsuario(@PathParam("id") Long id) {
        return HistoricoEnvio.find("usuarioId", id).list();
    }

    @GET
    @Path("historico/status/{status}")
    public List<HistoricoEnvio> porStatus(@PathParam("status") String status) {
        return HistoricoEnvio.find("status", status).list();
    }

    @GET
    @Path("historico/resumo")
    public Map<String, Long> resumo() {
        Map<String, Long> out = new LinkedHashMap<>();
        out.put("ENVIADO", HistoricoEnvio.count("status", "ENVIADO"));
        out.put("FALHA", HistoricoEnvio.count("status", "FALHA"));
        out.put("TOTAL", HistoricoEnvio.count());
        return out;
    }
}
