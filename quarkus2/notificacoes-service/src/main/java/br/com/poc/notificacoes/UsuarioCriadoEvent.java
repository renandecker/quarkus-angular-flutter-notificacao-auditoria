package br.com.poc.notificacoes;

import java.time.Instant;

/** Contrato do evento compartilhado com o servico de usuarios. */
public class UsuarioCriadoEvent {

    public Long usuarioId;
    public String nome;
    public String email;
    public Instant ocorridoEm;

    public UsuarioCriadoEvent() {
    }
}
