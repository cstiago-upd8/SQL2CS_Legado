import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';

import { Chamado } from './chamados.model';

/**
 * HTTP client for the Chamado API.
 *
 * Replaces the direct form posts and querystring navigation of the legacy pages
 * with typed calls against /api/chamados.
 */
@Injectable({ providedIn: 'root' })
export class ChamadosService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/api/chamados';

  /** Lists records, optionally filtered. */
  list(busca?: string | null, status?: string | null): Observable<Chamado[]> {
    let params = new HttpParams();
    if (busca) {
      params = params.set('busca', busca);
    }
    if (status) {
      params = params.set('status', status);
    }

    return this.http.get<Chamado[]>(this.baseUrl, { params });
  }

  /** Fetches a single record by key. */
  get(id: number): Observable<Chamado> {
    return this.http.get<Chamado>(`${this.baseUrl}/${id}`);
  }

  /** Creates or updates a record. */
  save(payload: Chamado): Observable<{ id: number }> {
    return this.http.post<{ id: number }>(this.baseUrl, payload);
  }

  /** Deletes a record and its history. */
  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }
}
