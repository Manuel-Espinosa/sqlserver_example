#!/bin/bash
set -e

echo "Esperando a que SQL Server esté disponible..."

until /opt/mssql-tools/bin/sqlcmd -S sqlserver-academic -U sa -P "YourStrong!Passw0rd" -Q "SELECT 1" &> /dev/null
do
    echo "SQL Server no está listo... esperando 3s"
    sleep 3
done

echo "SQL Server está listo. Ejecutando scripts..."

for file in /init/*.sql; do
    echo "Ejecutando script: $file"
    /opt/mssql-tools/bin/sqlcmd -S sqlserver-academic -U sa -P "YourStrong!Passw0rd" -i "$file"
done

echo "Todos los scripts han sido ejecutados."
