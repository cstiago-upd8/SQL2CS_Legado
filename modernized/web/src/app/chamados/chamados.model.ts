/**
 * Represents a Chamado.
 *
 * Derived from chamados.asp, excluir_chamado.asp, pesquisa_chamados.asp.
 */
export interface Chamado {
  chamadoId: number;
  titulo: string;
  descricao?: string;
  prioridade?: string;
  status?: string;
  tecnicoResp?: string;
  solucaoTecnica?: string;
  dataCriacao: string;
  dataAtualizacao?: string;
}

/** Allowed values for Prioridade, taken from the legacy select options. */
export const PRIORIDADE_VALUES = [
  'Baixa',
  'Media',
  'Alta',
  'Critica',
] as const;

export type Prioridade = typeof PRIORIDADE_VALUES[number];

/** Allowed values for Status, taken from the legacy select options. */
export const STATUS_VALUES = [
  'Aberto',
  'Em Andamento',
  'Aguardando',
  'Resolvido',
  'Fechado',
] as const;

export type Status = typeof STATUS_VALUES[number];
