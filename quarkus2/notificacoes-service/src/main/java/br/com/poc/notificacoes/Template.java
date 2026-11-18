package br.com.poc.notificacoes;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;

import io.quarkus.hibernate.orm.panache.PanacheEntity;

@Entity
@Table(name = "templates")
public class Template extends PanacheEntity {

    @Column(nullable = false, unique = true, length = 60)
    public String codigo;

    @Column(nullable = false, length = 200)
    public String assunto;

    @Column(nullable = false, length = 1000)
    public String corpo;
}
