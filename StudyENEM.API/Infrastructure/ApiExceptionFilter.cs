using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace StudyENEM.API.Infrastructure;

/// <summary>Converte as exceções de regra de negócio dos serviços em respostas HTTP com mensagem.</summary>
public class ApiExceptionFilter : IExceptionFilter
{
    public void OnException(ExceptionContext context)
    {
        int? status = context.Exception switch
        {
            KeyNotFoundException => StatusCodes.Status404NotFound,
            ArgumentException => StatusCodes.Status400BadRequest,
            InvalidOperationException => StatusCodes.Status409Conflict,
            UnauthorizedAccessException => StatusCodes.Status401Unauthorized,
            _ => null,
        };
        if (status is null) return;

        context.Result = new ObjectResult(new { message = context.Exception.Message }) { StatusCode = status };
        context.ExceptionHandled = true;
    }
}
