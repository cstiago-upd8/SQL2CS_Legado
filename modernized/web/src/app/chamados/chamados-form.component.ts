import { CommonModule } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';

import { Chamado } from './chamados.model';
import { ChamadosService } from './chamados.service';

/**
 * Create and edit form for Chamado.
 *
 * Replaces chamados.asp. The legacy page posted back to itself and issued
 * a Response.Redirect on success; this component submits through
 * ChamadosService and navigates with the Router.
 *
 * The Server.HTMLEncode calls are gone: Angular escapes interpolated values.
 */
@Component({
  selector: 'app-chamados-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `
    <section class="card">
      <header class="card-header">
        <h2>{{ isEditing ? 'Editar Chamado' : 'Novo Chamado' }}</h2>
      </header>

      <p class="message error" role="alert" *ngIf="errorMessage">{{ errorMessage }}</p>

      <form [formGroup]="form" (ngSubmit)="save()">
        <div class="form-group">
          <label for="titulo">Titulo <span aria-hidden="true">*</span></label>
          <input id="titulo" type="text" formControlName="titulo" class="form-control" />
          <small class="field-error" *ngIf="form.controls.titulo.touched && form.controls.titulo.invalid">
            Titulo e obrigatorio.
          </small>
        </div>
        <div class="form-group">
          <label for="descricao">Descricao <span aria-hidden="true">*</span></label>
          <textarea id="descricao" formControlName="descricao" class="form-control"></textarea>
          <small class="field-error" *ngIf="form.controls.descricao.touched && form.controls.descricao.invalid">
            Descricao e obrigatorio.
          </small>
        </div>
        <div class="form-group">
          <label for="prioridade">Prioridade</label>
          <select id="prioridade" formControlName="prioridade" class="form-control">
            <option value="Baixa">Baixa</option>
            <option value="Media">Media</option>
            <option value="Alta">Alta</option>
            <option value="Critica">Critica</option>
          </select>
        </div>
        <div class="form-group">
          <label for="status">Status</label>
          <select id="status" formControlName="status" class="form-control">
            <option value="Aberto">Aberto</option>
            <option value="Em Andamento">Em Andamento</option>
            <option value="Aguardando">Aguardando</option>
            <option value="Resolvido">Resolvido</option>
            <option value="Fechado">Fechado</option>
          </select>
        </div>
        <div class="form-group">
          <label for="tecnicoResp">Tecnico Responsavel</label>
          <input id="tecnicoResp" type="text" formControlName="tecnicoResp" class="form-control" />
        </div>
        <div class="form-group">
          <label for="solucaoTecnica">Solucao Tecnica</label>
          <textarea id="solucaoTecnica" formControlName="solucaoTecnica" class="form-control"></textarea>
        </div>

        <div class="btn-group">
          <button type="submit" class="btn btn-primary" [disabled]="form.invalid || saving">
            {{ saving ? 'Salvando...' : (isEditing ? 'Atualizar' : 'Salvar') }}
          </button>
          <button type="button" class="btn btn-secondary" (click)="cancel()">Cancelar</button>
        </div>
      </form>
    </section>
  `,
})
export class ChamadosFormComponent implements OnInit {
  private readonly service = inject(ChamadosService);
  private readonly formBuilder = inject(FormBuilder);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);

  protected saving = false;
  protected errorMessage = '';
  protected chamadoId: number | null = null;

  protected readonly form = this.formBuilder.group({
    titulo: ['', [Validators.required, Validators.maxLength(200)]],
    descricao: ['', [Validators.required, Validators.maxLength(4000)]],
    prioridade: ['Baixa', [Validators.maxLength(50)]],
    status: ['Aberto', [Validators.maxLength(50)]],
    tecnicoResp: ['', [Validators.maxLength(200)]],
    solucaoTecnica: ['', [Validators.maxLength(4000)]],
  });

  protected get isEditing(): boolean {
    return this.chamadoId !== null;
  }

  ngOnInit(): void {
    const id = this.route.snapshot.queryParamMap.get('id');
    if (id) {
      this.chamadoId = Number(id);
      this.load(this.chamadoId);
    }
  }

  private load(id: number): void {
    this.service.get(id).subscribe({
      next: (item) => item && this.form.patchValue(item),
      error: () => (this.errorMessage = 'Nao foi possivel carregar o registro.'),
    });
  }

  protected save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.saving = true;
    this.errorMessage = '';

    const payload = {
      ...this.form.getRawValue(),
      chamadoId: this.chamadoId,
    } as unknown as Chamado;

    this.service.save(payload).subscribe({
      next: () => this.router.navigate(['/chamados']),
      error: (response) => {
        // The API surfaces DomainException messages, which carry the business
        // rules the legacy PL/pgSQL routines enforced.
        this.errorMessage = response?.error?.message ?? 'Erro ao salvar.';
        this.saving = false;
      },
    });
  }

  protected cancel(): void {
    this.router.navigate(['/chamados']);
  }
}
