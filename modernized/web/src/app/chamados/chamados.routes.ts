import { Routes } from '@angular/router';

import { ChamadosListComponent } from './chamados-list.component';
import { ChamadosFormComponent } from './chamados-form.component';

/**
 * Routes for the Chamado feature.
 *
 * The legacy application navigated between .asp files; those transitions become
 * client-side routes here.
 *
 * Legacy redirect targets preserved:
 *   - pesquisa_chamados.asp
 */
export const CHAMADOS_ROUTES: Routes = [
  {
    path: 'chamados',
    component: ChamadosListComponent,
    title: 'Chamado - Lista',
  },
  {
    path: 'chamados/edit',
    component: ChamadosFormComponent,
    title: 'Chamado - Editar',
  },
  {
    path: '',
    redirectTo: 'chamados',
    pathMatch: 'full',
  },
];
