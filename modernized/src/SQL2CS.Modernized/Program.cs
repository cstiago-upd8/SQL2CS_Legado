using Microsoft.EntityFrameworkCore;
using SQL2CS.Modernized.Data;
using SQL2CS.Modernized.Services;
using SQL2CS.Modernized.Services.Interfaces;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

// The PostgreSQL schema is unchanged; only the access path is modernised.
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

builder.Services.AddScoped<IChamadoService, ChamadoService>();

var app = builder.Build();

app.UseHttpsRedirection();
app.MapControllers();

app.Run();
