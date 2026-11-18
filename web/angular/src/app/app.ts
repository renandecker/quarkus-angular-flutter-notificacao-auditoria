import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { ApiService } from './api.service';
import { HistoricoEnvio, Resumo, Usuario, Versao } from './models';

@Component({
  selector: 'app-root',
  imports: [FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  private readonly api = inject(ApiService);

  readonly versao = this.api.versao;
  readonly baseUsuarios = this.api.baseUsuarios;
  readonly baseNotificacoes = this.api.baseNotificacoes;

  readonly usuarios = signal<Usuario[]>([]);
  readonly historico = signal<HistoricoEnvio[]>([]);
  readonly resumo = signal<Resumo>({ ENVIADO: 0, FALHA: 0, TOTAL: 0 });

  readonly nome = signal('');
  readonly email = signal('');
  readonly erro = signal<string | null>(null);
  readonly aviso = signal<string | null>(null);
  readonly carregando = signal(false);
  readonly latenciaMs = signal<number | null>(null);

  constructor() {
    this.recarregar();
  }

  usarVersao(v: Versao): void {
    if (this.versao() === v) return;
    this.versao.set(v);
    this.erro.set(null);
    this.recarregar();
  }

  recarregar(): void {
    this.carregando.set(true);

    this.api.listarUsuarios().subscribe({
      next: (lista) => this.usuarios.set([...lista].reverse()),
      error: (e) => this.mostrarErro('Não foi possível listar usuários', e),
    });

    this.api.listarHistorico().subscribe({
      next: (lista) => this.historico.set(lista),
      error: (e) => this.mostrarErro('Não foi possível listar o histórico', e),
    });

    this.api.resumo().subscribe({
      next: (r) => {
        this.resumo.set(r);
        this.carregando.set(false);
      },
      error: (e) => {
        this.mostrarErro('Não foi possível ler o resumo', e);
        this.carregando.set(false);
      },
    });
  }

  criar(): void {
    const nome = this.nome().trim();
    const email = this.email().trim();
    if (!nome || !email || !email.includes('@')) {
      this.erro.set('Informe nome e e-mail válidos.');
      return;
    }

    this.carregando.set(true);
    this.erro.set(null);
    const inicio = performance.now();

    this.api.criarUsuario(nome, email).subscribe({
      next: (usuario) => {
        const ms = Math.round(performance.now() - inicio);
        this.latenciaMs.set(ms);
        this.nome.set('');
        this.email.set('');
        this.aviso.set(`201 Created • id=${usuario.id} • ${ms} ms (sem esperar o SMTP)`);
        this.recarregar();
      },
      error: (e) => {
        this.carregando.set(false);
        this.mostrarErro('Falha ao cadastrar', e);
      },
    });
  }

  private mostrarErro(contexto: string, e: any): void {
    const detalhe = e?.error?.message ?? e?.message ?? 'serviço indisponível';
    this.erro.set(`${contexto}: ${detalhe}`);
  }
}
