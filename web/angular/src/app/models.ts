export type Versao = 'q2' | 'q3' | 'q4';

export interface Usuario {
  id: number;
  nome: string;
  email: string;
  criadoEm?: string;
  atualizadoEm?: string;
}

export interface HistoricoEnvio {
  id: number;
  usuarioId: number;
  nome: string;
  email: string;
  templateCodigo: string;
  assunto: string;
  mensagem: string;
  status: 'ENVIADO' | 'FALHA' | string;
  detalhe: string;
  criadoEm: string;
  duracaoMs: number;
  versaoQuarkus: string;
}

export interface Resumo {
  ENVIADO: number;
  FALHA: number;
  TOTAL: number;
}
