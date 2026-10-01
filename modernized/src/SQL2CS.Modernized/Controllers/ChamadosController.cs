using Microsoft.AspNetCore.Mvc;
using SQL2CS.Modernized.DTOs;
using SQL2CS.Modernized.Services.Interfaces;
using SQL2CS.Modernized.Exceptions;

namespace SQL2CS.Modernized.Controllers;

/// <summary>
/// REST endpoints for the Chamado resource.
/// </summary>
/// <remarks>
/// Replaces the following legacy ASP pages:
/// <list type="bullet">
///   <item><description>chamados.asp (crud_form)</description></item>
///   <item><description>excluir_chamado.asp (action_handler)</description></item>
///   <item><description>pesquisa_chamados.asp (list_search)</description></item>
/// </list>
///
/// The legacy pages opened an <c>ADODB.Connection</c> directly and built SQL by
/// string concatenation. Data access now goes through
/// <c>IChamadoService</c>, which uses parameterised EF Core queries.
/// </remarks>
[ApiController]
[Route("api/chamados")]
public sealed class ChamadosController : ControllerBase
{
    private readonly IChamadoService _service;
    private readonly ILogger<ChamadosController> _logger;

    public ChamadosController(IChamadoService service, ILogger<ChamadosController> logger)
    {
        _service = service;
        _logger = logger;
    }

    /// <summary>Lists Chamado records, optionally filtered.</summary>
    /// <remarks>Replaces pesquisa_chamados.asp.</remarks>
    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar([FromQuery] string? busca = null, [FromQuery] string? status = null)
    {
        var items = await _service.ListarAsync(busca, status);
        return Ok(items);
    }

    /// <summary>Fetches a single Chamado by its key.</summary>
    /// <remarks>Replaces chamados.asp.</remarks>
    [HttpGet("{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Obter([FromRoute] int id)
    {
        var item = await _service.ObterAsync(id);

        if (item is null)
        {
            _logger.LogInformation("Chamado {Id} not found", id);
            return NotFound();
        }

        return Ok(item);
    }

    /// <summary>Creates or updates a Chamado.</summary>
    /// <remarks>Replaces chamados.asp.</remarks>
    [HttpPost]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Salvar([FromBody] ChamadoRequest request)
    {
        try
        {
            var id = await _service.SalvarAsync(request);
            return Ok(new { id });
        }
        catch (DomainException exception)
        {
            // Carries a business rule the legacy PL/pgSQL routine raised.
            _logger.LogInformation("Business rule rejected the request: {Message}", exception.Message);
            return BadRequest(new { message = exception.Message });
        }
    }

    /// <summary>Deletes a Chamado and its history.</summary>
    /// <remarks>Replaces excluir_chamado.asp.</remarks>
    [HttpDelete("{chamadoId}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Excluir([FromRoute] int chamadoId)
    {
        try
        {
            await _service.ExcluirAsync(chamadoId);
            return NoContent();
        }
        catch (DomainException exception)
        {
            return BadRequest(new { message = exception.Message });
        }
    }
}
