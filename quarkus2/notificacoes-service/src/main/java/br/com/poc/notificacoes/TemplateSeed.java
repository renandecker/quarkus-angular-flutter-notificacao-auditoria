package br.com.poc.notificacoes;

import javax.enterprise.context.ApplicationScoped;
import javax.enterprise.event.Observes;
import javax.transaction.Transactional;

import io.quarkus.runtime.StartupEvent;

/** Base propria de templates, semeada na subida do worker. */
@ApplicationScoped
public class TemplateSeed {

    void onStart(@Observes StartupEvent event) {
        semear();
    }

    @Transactional
    void semear() {
        criar("BOAS_VINDAS",
              "Bem-vindo(a), {nome}!",
              "Ola {nome}, sua conta {email} foi criada com sucesso. Id: {usuarioId}.");
        criar("BOAS_VINDAS_PREMIUM",
              "Seu acesso Premium esta ativo, {nome}!",
              "Ola {nome}! Recebemos {email} (usuario {usuarioId}) no plano Premium. Aproveite!");
    }

    private void criar(String codigo, String assunto, String corpo) {
        if (Template.count("codigo", codigo) == 0) {
            Template t = new Template();
            t.codigo = codigo;
            t.assunto = assunto;
            t.corpo = corpo;
            t.persist();
        }
    }
}
