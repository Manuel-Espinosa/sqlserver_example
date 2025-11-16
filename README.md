# Proyecto SQL Server Académico

Este proyecto contiene un entorno completo para levantar una base de
datos académica en SQL Server usando Docker. Incluye scripts de esquema,
datos de ejemplo y consultas.

## Estructura del proyecto

-   **docker-compose.yml**: configura SQL Server y el contenedor que
    inicializa la base.
-   **sql/schema.sql**: crea la base de datos y las tablas.
-   **sql/seed.sql**: inserta datos de ejemplo.
-   **sql/queries.sql**: contiene consultas útiles.
-   **diagrams/**: diagramas.
-   **README.md**: documentación del proyecto.
  
## Diagrama Entidad-Relación

- La base de datos está organizada como un sistema académico, en el que estudiantes, profesores, departamentos, materias y grupos se relacionan de forma coherente para administrar inscripciones y actividades docentes.
- Los estudiantes se inscriben en grupos, los cuales pertenecen a una materia. Los profesores pueden impartir uno o varios grupos, y cada profesor pertenece a un departamento, que además tiene un director asignado (también un profesor del mismo departamento).
- El diseño permite registrar inscripciones, calificaciones, cargas docentes, estructura académica y asignación de cursos de manera flexible y normalizada.

![Diagrama ER](diagrams/er_diagram.md)

## Requisitos

-   Docker
-   Docker Compose
-   Archivo .env (ver .env-example)

## Cómo ejecutar

1.  Ejecutar:

    ``` bash
    docker compose up --build
    ```

2.  Esperar a que aparezca el mensaje:

        Database schema created successfully!

    y varias líneas del tipo:

        (X rows affected)

3.  El contenedor `init-db` se ejecuta una sola vez y sale. El
    contenedor `sqlserver` queda corriendo con la base creada y poblada.

4. Dar permisos en backups para que el contendor pueda escribir el backup
   
   ```bash
   chmod 777 backups
   ```

## Conectarse a SQL Server

-   **Host:** localhost
-   **Puerto:** 1433
-   **Usuario:** sa
-   **Contraseña:** Your_password123
-   **Base de datos:** AcademicDB

Puedes conectarte con Azure Data Studio, DBeaver o `sqlcmd`.

## Comandos útiles

-   **Crear red para el conteneror**

    ```bash
    docker network create sqlserver_network
    ```

-   **Reiniciar todo desde cero (incluyendo volúmenes):**

    ``` bash
    docker compose down -v && docker compose up --build
    ```

-   **Ver logs en tiempo real:**

    ``` bash
    docker compose logs -f
    ```

-   **Entrar al cmd de SQL Server:**

    ``` bash
    docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Your_password123
    ```

-   **Generar backup**
    ```bash
    docker exec -it sqlserver-academic   /opt/mssql-tools18/bin/sqlcmd   -S localhost -U SA -P 'Your_password123' -C -Q "BACKUP DATABASE AcademicDB TO DISK='/var/opt/mssql/backups/AcademicDB.bak' WITH INIT"
    ```

## Notas

-   El contenedor `init-db` ejecuta los scripts en orden:

    1.  `schema.sql`
    2.  `seed.sql`
    3.  `queries.sql`

-   Si modificas los scripts, debes recrear los volúmenes:

    ``` bash
    docker compose down -v
    ```
