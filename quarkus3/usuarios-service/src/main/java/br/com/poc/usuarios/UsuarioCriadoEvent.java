package br.com.poc.usuarios;

import java.time.Instant;

/** Evento leve: apenas o necessario para o worker formatar a notificacao. */
public class UsuarioCriadoEvent {

    public Long usuarioId;
    public String nome;
    public String email;
    public Instant ocorridoEm;

    public UsuarioCriadoEvent() {
    }

    public UsuarioCriadoEvent(Long usuarioId, String nome, String email, Instant ocorridoEm) {
        this.usuarioId = usuarioId;
        this.nome = nome;
        this.email = email;
        this.ocorridoEm = ocorridoEm;
    }
}
