import { computed, inject, Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { HistoricoEnvio, Resumo, Usuario, Versao } from './models';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly http = inject(HttpClient);

  /** Alterna entre as duas implementações completas da PoC. */
  readonly versao = signal<Versao>('q2');

  readonly baseUsuarios = computed(() => {
    switch (this.versao()) {
      case 'q2': return 'http://localhost:8081';
      case 'q3': return 'http://localhost:8085';
      case 'q4': return 'http://localhost:8083';
    }
  });

  readonly baseNotificacoes = computed(() => {
    switch (this.versao()) {
      case 'q2': return 'http://localhost:8082';
      case 'q3': return 'http://localhost:8086';
      case 'q4': return 'http://localhost:8084';
    }
  });

  listarUsuarios(): Observable<Usuario[]> {
    return this.http.get<Usuario[]>(`${this.baseUsuarios()}/usuarios`);
  }

  criarUsuario(nome: string, email: string): Observable<Usuario> {
    return this.http.post<Usuario>(`${this.baseUsuarios()}/usuarios`, { nome, email });
  }

  listarHistorico(): Observable<HistoricoEnvio[]> {
    return this.http.get<HistoricoEnvio[]>(`${this.baseNotificacoes()}/historico`);
  }

  resumo(): Observable<Resumo> {
    return this.http.get<Resumo>(`${this.baseNotificacoes()}/historico/resumo`);
  }
}
