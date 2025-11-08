FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY . .

RUN dotnet restore
RUN dotnet publish WebApi/WebApi.csproj -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

COPY --from=build /out .

RUN apt-get update && apt-get install -y curl

EXPOSE 80

ENTRYPOINT ["dotnet", "WebApi.dll"]