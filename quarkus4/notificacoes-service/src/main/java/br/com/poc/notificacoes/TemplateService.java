package br.com.poc.notificacoes;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

/** Leitura do template em transação própria: o consumer roda fora de um request context. */
@ApplicationScoped
public class TemplateService {

    @Transactional
    public Template buscar(String codigo) {
        return Template.find("codigo", codigo).firstResult();
    }
}
