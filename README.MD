# Examen Final - Base de Datos Chinook

## 📌 Descripción del Proyecto
Este proyecto corresponde al **Examen Final** de la materia de Bases de Datos, el cual utiliza la base de datos **Chinook**.  
El objetivo principal es implementar y demostrar el uso de **DDL, DML, DQL, funciones, eventos y triggers** sobre una base de datos relacional que gestiona un sistema de música digital.

La base de datos Chinook contiene información de:
- Artistas, álbumes, pistas y géneros musicales.
- Listas de reproducción y sus canciones.
- Clientes y empleados.
- Facturas y líneas de factura.

En este examen se desarrollan scripts que:
- Crean la estructura de la base de datos (**DDL**).
- Insertan datos iniciales (**DML**).
- Ejecutan consultas avanzadas (**SELECT**).
- Implementan funciones personalizadas (**FUNCTIONS**).
- Definen eventos programados (**EVENTS**).
- Crean disparadores automáticos (**TRIGGERS**).

---

## 🖥️ Requisitos del Sistema
Para ejecutar correctamente el proyecto se requiere:
- **MySQL** versión 8.0 o superior.
- **MySQL Workbench** o cualquier cliente MySQL compatible.
- Sistema operativo Windows, Linux o macOS.
- Permisos para habilitar el **Event Scheduler** en MySQL (para ejecutar eventos programados).

---

## ⚙️ Instalación y Configuración

### 1️⃣ Clonar o descargar el repositorio
```bash

git clone <URL_DEL_REPOSITORIO>

O descargarlo como archivo .zip y extraerlo.

2️⃣ Cargar la estructura de la base de datos

En MySQL Workbench o consola:

SOURCE ddl.sql;


Esto creará todas las tablas y relaciones necesarias.

3️⃣ Insertar datos iniciales
SOURCE dml.sql;

4️⃣ Ejecutar consultas y ejercicios

Consultas SELECT:

SOURCE dql_select.sql;


Funciones:

SOURCE dql_funciones.sql;


Eventos:

SOURCE dql_eventos.sql;


Triggers:

SOURCE dql_triggers.sql;


📌 Nota: Para que los eventos se ejecuten automáticamente:

SET GLOBAL event_scheduler = ON;

📂 Estructura de Archivos
📦 Proyecto
 ┣ 📂 archivos MYSQL
 ┃ ┣ 📜 ddl.sql                # Script para crear la estructura de la base de datos
 ┃ ┣ 📜 dml.sql                # Script para insertar datos iniciales
 ┃ ┣ 📜 dql_select.sql         # Consultas SELECT
 ┃ ┣ 📜 dql_funciones.sql      # Funciones personalizadas
 ┃ ┣ 📜 dql_eventos.sql        # Eventos programados
 ┃ ┣ 📜 dql_triggers.sql       # Disparadores (triggers)
 ┃ ┣ 📜 Chinook_MySql.sql      # Script completo de la base de datos original
 ┗ 📜 README.md                # Documentación del proyecto

📝 Notas Finales

Todos los scripts incluyen comentarios explicativos sobre su funcionamiento.

La base de datos Chinook es utilizada para fines académicos y de práctica en SQL.

El proyecto demuestra habilidades en modelado, consultas, procedimientos, eventos y triggers en MySQL.

Hecho por David Alejandro Ardila Cardozo.