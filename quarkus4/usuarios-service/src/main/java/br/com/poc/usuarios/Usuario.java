package br.com.poc.usuarios;

import java.time.Instant;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

import io.quarkus.hibernate.orm.panache.PanacheEntity;

@Entity
@Table(name = "usuarios")
public class Usuario extends PanacheEntity {

    @NotBlank
    @Column(nullable = false, length = 120)
    public String nome;

    @NotBlank
    @Email
    @Column(nullable = false, unique = true, length = 180)
    public String email;

    @Column(nullable = false)
    public Instant criadoEm;

    @Column
    public Instant atualizadoEm;
}
