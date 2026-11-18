package br.com.poc.notificacoes;

import java.time.Instant;
import javax.enterprise.context.ApplicationScoped;
import javax.transaction.Transactional;

@ApplicationScoped
public class HistoricoService {

    @Transactional
    public void registrar(Long usuarioId, String email, String nome, String templateCodigo,
                          String assunto, String mensagem, String status, String detalhe,
                          Instant criadoEm, long duracaoMs) {
        HistoricoEnvio h = new HistoricoEnvio();
        h.usuarioId = usuarioId;
        h.email = email;
        h.nome = nome;
        h.templateCodigo = templateCodigo;
        h.assunto = assunto;
        h.mensagem = mensagem;
        h.status = status;
        h.detalhe = detalhe;
        h.criadoEm = criadoEm;
        h.duracaoMs = duracaoMs;
        h.persist();
    }
}
