import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { Router } from '@angular/router';

import { Chamado } from './chamados.model';
import { ChamadosService } from './chamados.service';

/**
 * Filtered listing for Chamado.
 *
 * Replaces pesquisa_chamados.asp. The legacy page rendered rows with a
 * Do While Not rs.EOF loop and mapped values onto CSS classes with Select Case;
 * both become template constructs here.
 */
@Component({
  selector: 'app-chamados-list',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <section class="card">
      <form [formGroup]="filters" (ngSubmit)="search()" class="filters">
        <div class="filter-group">
          <label for="busca">Buscar</label>
          <input id="busca" type="search" formControlName="busca" class="form-control" />
        </div>
        <div class="filter-group">
          <label for="status">Status</label>
          <select id="status" formControlName="status" class="form-control">
            <option value="">Todos</option>
            <option value="Aberto">Aberto</option>
            <option value="Em Andamento">Em Andamento</option>
            <option value="Aguardando">Aguardando</option>
            <option value="Resolvido">Resolvido</option>
            <option value="Fechado">Fechado</option>
          </select>
        </div>
        <button type="submit" class="btn btn-primary">Pesquisar</button>
      </form>
    </section>

    <section class="card">
      <p *ngIf="loading">Carregando...</p>
      <p *ngIf="!loading && items.length === 0">Nenhum registro encontrado.</p>

      <table class="data-table" *ngIf="!loading && items.length > 0">
        <caption>Chamado encontrados: {{ items.length }}</caption>
        <thead>
          <tr>
            <th scope="col">ChamadoId</th>
            <th scope="col">Titulo</th>
            <th scope="col">Prioridade</th>
            <th scope="col">Status</th>
            <th scope="col">TecnicoResp</th>
            <th scope="col">DataCriacao</th>
            <th scope="col">DataAtualizacao</th>
            <th scope="col">Acoes</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let item of items">
            <td>{{ item.chamadoId }}</td>
            <td>{{ item.titulo }}</td>
            <td><span class="badge" [class]="prioridadeClass(item.prioridade)">{{ item.prioridade }}</span></td>
            <td><span class="badge" [class]="statusClass(item.status)">{{ item.status }}</span></td>
            <td>{{ item.tecnicoResp }}</td>
            <td>{{ item.dataCriacao | date: 'dd/MM/yyyy HH:mm' }}</td>
            <td>{{ item.dataAtualizacao | date: 'dd/MM/yyyy HH:mm' }}</td>
            <td class="actions">
              <button type="button" class="btn btn-sm" (click)="edit(item.chamadoId)">Editar</button>
              <button type="button" class="btn btn-sm btn-danger" (click)="remove(item.chamadoId)">Excluir</button>
            </td>
          </tr>
        </tbody>
      </table>
    </section>
  `,
})
export class ChamadosListComponent implements OnInit {
  private readonly service = inject(ChamadosService);
  private readonly formBuilder = inject(FormBuilder);
  private readonly router = inject(Router);

  protected items: Chamado[] = [];
  protected loading = false;

  protected readonly filters = this.formBuilder.group({
    busca: [''],
    status: [''],
  });

  ngOnInit(): void {
    this.search();
  }

  protected search(): void {
    this.loading = true;
    const { busca, status } = this.filters.getRawValue();

    this.service.list(busca, status).subscribe({
      next: (items) => {
        this.items = items;
        this.loading = false;
      },
      error: () => (this.loading = false),
    });
  }

  protected edit(id: number): void {
    this.router.navigate(['/chamados/edit'], { queryParams: { id } });
  }

  protected remove(id: number): void {
    // The legacy page used a window.confirm before navigating to the delete
    // handler; the guard is kept but the call is now a typed DELETE.
    if (!confirm(`Deseja realmente excluir o registro #${id}?`)) {
      return;
    }

    this.service.delete(id).subscribe({
      next: () => this.search(),
    });
  }

  /** CSS class for a Prioridade value, replacing the legacy Select Case. */
  protected prioridadeClass(value: string | null | undefined): string {
    switch ((value ?? '').toLowerCase()) {
      case 'baixa':
        return 'badge-baixa';
      case 'media':
        return 'badge-media';
      case 'alta':
        return 'badge-alta';
      case 'critica':
        return 'badge-critica';
      default:
        return 'badge-default';
    }
  }

  /** CSS class for a Status value, replacing the legacy Select Case. */
  protected statusClass(value: string | null | undefined): string {
    switch ((value ?? '').toLowerCase()) {
      case 'aberto':
        return 'badge-aberto';
      case 'em andamento':
        return 'badge-em-andamento';
      case 'aguardando':
        return 'badge-aguardando';
      case 'resolvido':
        return 'badge-resolvido';
      case 'fechado':
        return 'badge-fechado';
      default:
        return 'badge-default';
    }
  }
}
