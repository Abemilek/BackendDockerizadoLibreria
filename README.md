# Backend Dockerizado de la Librería
Este proyecto es un backend ASP.NET Core listo para Docker + SQL Server.

Requisitos:
- Docker instalado
- Docker Compose (incluido en Docker Desktop)

Crear un archivo `.env` en la raíz del proyecto:
MSSQL_SA_PASSWORD=`password`
ASPNETCORE_ENVIRONMENT=Development

`docker compose up -d --build`
