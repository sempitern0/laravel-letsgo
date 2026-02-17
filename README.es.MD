# 🚀 Laravel Let's Go - Entorno de desarrollo
[Read in English 🇺🇸](README.MD)

Este es un entorno de desarrollo profesional basado en [Docker](https://www.docker.com/), diseñado para proyectos **PHP/Laravel**, pero lo suficientemente flexible para cualquier aplicación web basada en PHP. 

Cuenta con soporte para múltiples bases de datos *(MySQL/Postgres)* mediante los [perfiles de docker](https://docs.docker.com/compose/how-tos/profiles/), Proxy HTTPS con certificados locales, Redis, [Mailpit](https://mailpit.axllent.org/) y herramientas de gestión de datos *(phpMyAdmin/pgAdmin)*.

## 📋 Requisitos Previos

Asegúrate de tener instaladas las siguientes herramientas según tu sistema operativo:

### 1. Docker & Docker Compose
En su [página oficial](https://docs.docker.com/get-started/get-docker/) tienen disponibles las guías de instalación para cada sistema operativo.

- [Instalación de Docker en Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Instalación de Docker en Linux](https://docs.docker.com/desktop/setup/install/linux/)
- [Instalación de Docker en MacOS](https://docs.docker.com/desktop/setup/install/mac-install/)

### 2. mkcert (Para HTTPS Local)

Esta herramienta crea certificados SSL válidos y confiables para tu navegador, sigue las instrucciones en su [repositorio oficial]((https://github.com/FiloSottile/mkcert)) para la instalación en tu sistema operativo.

*Este repositorio viene definido con el dominio `myapp.local`, si quieres otro nombre de dominio deberás cambiarlo en el archivo de configuración de nginx `images/nginx/proxy.conf` y a la hora de generar los certificados.*

```bash
# Instalar la Autoridad de Certificación local (Solo la primera vez)
mkcert -install

# Generar los certificados, usa la raíz de este proyecto a la hora de lanzar el comando.
mkcert -key-file images/nginx/certs/myapp.key -cert-file images/nginx/certs/myapp.crt myapp.local
```

#### Configurar el Host local
Debes decirle a tu sistema que `myapp.local` apunta a tu máquina. Edita tu archivo host segun tu SO:

- Windows: `C:\Windows\System32\drivers\etc\hosts`
- Mac/Linux: `/etc/hosts`


```bash
# Archivo hosts
127.0.0.1  myapp.local
```

## Configurar el archivo .env
Duplica el archivo `.env.example` que encontrarás en la raíz de este proyecto y renombralo a `.env`, es importante que tenga este nombre ya que Docker lo lee por defecto sin necesidad de definir su path de forma manual en los archivos de configuracion.

La propiedad `COMPOSE_PROFILES` permite levantar la base de datos `mysql` o `postgres` segun el perfil que selecciones. Si quieres levantar ambas separalas por comas tal que asi `COMPOSE_PROFILES=mysql,postgres`.

La propiedad `APPLICATION_FOLDER` define el path hacia la carpeta donde está tu proyecto de laravel. Esta carpeta sera servida por nginx.

```nginx
COMPOSE_PROFILES=mysql #postgres

USER=laravel_user
USER_UID=1000
USER_GID=1000

CONTAINER_PREFIX=laravel_app
APPLICATION_FOLDER=LARAVEL_FOLDER_HERE # Your application where laravel files are.
DOCKER_RESTART_POLICY=no

## This credentials are local environment oriented - DON'T USE ON PRODUCTION!
DB_NAME=laravel_db
DB_EMAIL=admin@admin.com
DB_USER=admin
DB_USER_PASSWORD=secret
DB_ROOT_PASSWORD=secret
DB_ALLOW_EMPTY_PASSWORD=yes
DB_PORT=3306

REDIS_PASSWORD=secret
```

## Construir y levantar el entorno
Una vez tengas todas las propiedades configuradas y los certificados creados, procedemos a construir y levantar los contenedores.

Para construir las imágenes y levantar los contenedores , ejecuta el siguiente comando en tu terminal:

```bash

docker compose up --build

# Aplica el flag -d si lo quieres en modo detached (segundo plano) para tener esa sesión de terminal liberada.
docker compose up -d --build
```

## Ejecutar comandos de laravel
Si necesitas ejecutar los comandos habituales de laravel puedes acceder al contenedor `laravel_app` con:

```bash
docker compose exec -it laravel_app <TU_COMANDO>

## Ejemplo
docker compose exec -it laravel_app php artisan tinker
```

*El flag --build asegura que cualquier cambio realizado en los archivos de configuración de images/ o en las variables de entorno se aplique correctamente reconstruyendo las imágenes necesarias.*

## Detener los servicios
Dependiendo de lo que necesites hacer, tienes varias opciones para detener el entorno:

### Detener los contenedores
Utiliza este comando si quieres liberar RAM pero planeas volver pronto. Mantiene el estado de los contenedores.

```bash
docker compose stop
```

### Bajar los servicios
Detiene y elimina los contenedores y las redes internas de Docker. Los datos de la base de datos se mantienen seguros en los volúmenes persistentes.

```bash
docker compose down
```

### Reset total
Este comando elimina los contenedores y borra todos los datos de la base de datos, correos de `Mailpit` y datos de `Redis`. Úsalo solo si quieres empezar el proyecto desde cero absoluto.

```bash
docker compose down -v
```

## Configurar el .env de Laravel para conectarse a los servicios

```nginx
# Opcional si has definido un dominio personalizado
APP_URL=https://myapp.local #http://localhost:8000


DB_CONNECTION=mysql # usa pgsql si prefieres utilizar el driver de postgres
DB_HOST=mysql_db # usa postgres_db si quieres conectarte al contenedor de postgres
DB_PORT=3306

# Los siguientes datos deben ser iguales que los que has definido en el .env de configuracion de docker
DB_DATABASE=laravel_db
DB_USERNAME=admin
DB_PASSWORD=secret

REDIS_CLIENT=phpredis
REDIS_HOST=redis # nombre del contenedor de redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_SCHEME=null
MAIL_HOST=mailpit # nombre del contenedor de mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS="laravel@example.com"
MAIL_FROM_NAME="${APP_NAME}"
```

## 🔗 Servicios GUI disponibles

Puedes sustituir tu dominio local personalizado (`myapp.local`) por `localhost` si lo prefieres para acceder a estos servicios. 

> **Nota:** `phpMyAdmin` y `pgAdmin` solo estarán disponibles si has activado el perfil correspondiente en tu `.env` (`mysql` o `postgres`).

| Servicio | URL / Host | Puerto Local |
| :--- | :--- | :--- |
| **Web App (HTTPS)** | [https://myapp.local:8080](https://myapp.local:8080) | `8080` |
| **Web App (HTTP)** | [http://myapp.local:8085](http://myapp.local:8085) | `8085` |
| **Mailpit (UI)** | [http://myapp.local:8025](http://myapp.local:8025) | `8025` |
| **phpMyAdmin** | [http://myapp.local:8383](http://myapp.local:8383) | `8383` |
| **pgAdmin** | [http://myapp.local:8080](http://myapp.local:8080) | `8080` |
| **Redis Insight** | [http://myapp.local:5540](http://myapp.local:5540) | `5540` |

---
Desarrollado con ❤️ para agilizar el despliegue local. ¡Happy coding! 🚀