namespace SQL2CS.Modernized.Exceptions;

/// <summary>
/// Raised when a business rule rejects an operation.
/// </summary>
/// <remarks>
/// The legacy PL/pgSQL routines enforced their rules with
/// <c>RAISE EXCEPTION</c>, which surfaced to the ASP page as an ADO error and was
/// rendered in a banner. This exception carries the same messages, and the
/// controllers translate it into a 400 response so the Angular form can display
/// it.
///
/// Rules preserved from the legacy schema:
/// <list type="bullet">
///   <item><description>Chamado nao encontrado.</description></item>
///   <item><description>A solucao tecnica deve ser preenchida para resolver ou fechar o chamado.</description></item>
/// </list>
/// </remarks>
public class DomainException : Exception
{
    public DomainException(string message)
        : base(message)
    {
    }

    public DomainException(string message, Exception innerException)
        : base(message, innerException)
    {
    }
}
