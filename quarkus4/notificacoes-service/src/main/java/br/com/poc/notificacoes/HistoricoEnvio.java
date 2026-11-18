package br.com.poc.notificacoes;

import java.time.Instant;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

import io.quarkus.hibernate.orm.panache.PanacheEntity;

@Entity
@Table(name = "historico_envios")
public class HistoricoEnvio extends PanacheEntity {

    @Column(nullable = false)
    public Long usuarioId;

    @Column(nullable = false, length = 180)
    public String email;

    @Column(length = 120)
    public String nome;

    @Column(length = 60)
    public String templateCodigo;

    @Column(length = 200)
    public String assunto;

    @Column(length = 1000)
    public String mensagem;

    /** ENVIADO ou FALHA */
    @Column(nullable = false, length = 20)
    public String status;

    @Column(length = 300)
    public String detalhe;

    @Column(nullable = false)
    public Instant criadoEm;

    @Column(nullable = false)
    public long duracaoMs;

    @Column(nullable = false)
    public String versaoQuarkus = "4";
}
