# 🚀 Laravel Let's Go - Development Environment
[Leer en Español 🇪🇸](README.es.MD)

This is a professional development environment based on [Docker](https://www.docker.com/), designed for **PHP/Laravel** projects, yet flexible enough for any PHP-based web application.

It features support for multiple databases *(MySQL/Postgres)* via [Docker profiles](https://docs.docker.com/compose/how-tos/profiles/), HTTPS Proxy with local certificates, Redis, [Mailpit](https://mailpit.axllent.org/), and data management tools *(phpMyAdmin/pgAdmin)*.

## 📋 Prerequisites

Ensure you have the following tools installed according to your operating system:

### 1. Docker & Docker Compose
Installation guides for each OS are available on their [official website](https://docs.docker.com/get-started/get-docker/).

- [Install Docker on Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Install Docker on Linux](https://docs.docker.com/desktop/setup/install/linux/)
- [Install Docker on MacOS](https://docs.docker.com/desktop/setup/install/mac-install/)

### 2. mkcert (For Local HTTPS)

This tool creates valid and trusted SSL certificates for your browser. Follow the instructions in the [official repository](https://github.com/FiloSottile/mkcert) for installation.

*This repository is pre-configured with the `myapp.local` domain. If you wish to use a different domain name, you must change it in the Nginx configuration file `images/nginx/proxy.conf` and when generating the certificates.*

```bash
# Install the local CA (First time only)
mkcert -install

# Generate certificates - run this command from the project root.
mkcert -key-file images/nginx/certs/myapp.key -cert-file images/nginx/certs/myapp.crt myapp.local
```

## Configure Local Host
You must tell your system that myapp.local points to your machine. Edit your hosts file according to your OS:

- Windows: `C:\Windows\System32\drivers\etc\hosts`
- Mac/Linux: `/etc/hosts`

```bash
# Hosts file
127.0.0.1  myapp.local
```

## Configure the .env file
Duplicate the .env.example file found in the project root and rename it to .env. This name is important as Docker reads it by default.

The `COMPOSE_PROFILES` property allows you to spin up mysql or postgres depending on the selected profile. To launch both, separate them with commas: `COMPOSE_PROFILES=mysql,postgres`

The `APPLICATION_FOLDER` property defines the path to your Laravel project folder. This folder will be served by Nginx.

```nginx
COMPOSE_PROFILES=mysql #postgres

USER=laravel_user
USER_UID=1000
USER_GID=1000

CONTAINER_PREFIX=laravel_app
APPLICATION_FOLDER=LARAVEL_FOLDER_HERE # Your application path
DOCKER_RESTART_POLICY=no

## These credentials are local environment oriented - DO NOT USE IN PRODUCTION!
DB_NAME=laravel_db
DB_EMAIL=admin@admin.com
DB_USER=admin
DB_USER_PASSWORD=secret
DB_ROOT_PASSWORD=secret
DB_ALLOW_EMPTY_PASSWORD=yes
DB_PORT=3306

REDIS_PASSWORD=secret
```
## Build and Start the Environment
Once all properties are configured and certificates are created, proceed to build and start the containers.

To build the images and start the containers, run the following command in your terminal:

```bash
docker compose up --build

# Add the -d flag to run in detached mode (background)
docker compose up -d --build
```


## Running Laravel Commands
If you need to run standard Laravel commands, you can access the laravel_app container using:

```bash
docker compose exec -it laravel_app <YOUR_COMMAND>

## Example
docker compose exec -it laravel_app php artisan tinker
```

*The --build flag ensures that any changes made to configuration files in images/ or environment variables are correctly applied by rebuilding the necessary images.*


## Stopping Services
Depending on your needs, you have several options to stop the environment:

### Stop Containers
Use this command to free up RAM but keep the container state.

```bash
docker compose stop
```

### Shut Down Services
Stops and removes containers and internal Docker networks. Database data remains safe in persistent volumes.

```bash
docker compose down
```

### Total Reset
This command removes containers and deletes all data from the database, Mailpit emails, and Redis. Use only if you want to start the project from scratch.

```bash
docker compose down -v
```

## Configure Laravel's .env to connect to services

```nginx
# Optional if you defined a custom domain
APP_URL=[https://myapp.local](https://myapp.local) #http://localhost:8000

DB_CONNECTION=mysql # use pgsql for postgres driver
DB_HOST=mysql_db # use postgres_db for postgres container
DB_PORT=3306

# These must match your Docker .env configuration
DB_DATABASE=laravel_db
DB_USERNAME=admin
DB_PASSWORD=secret

REDIS_CLIENT=phpredis
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_SCHEME=null
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS="laravel@example.com"
MAIL_FROM_NAME="${APP_NAME}"
```

# 🔗 Available GUI Services
You can substitute your custom local domain `myapp.local` with `localhost` if preferred.

*> **Note:** `phpMyAdmin` and `pgAdmin` will only be available if you have activated the corresponding profile in your .`env` (mysql or postgres).*

| Service | URL / Host | Local port|
| :--- | :--- | :--- |
| **Web App (HTTPS)** | [https://myapp.local:8080](https://myapp.local:8080) | `8080` |
| **Web App (HTTP)** | [http://myapp.local:8085](http://myapp.local:8085) | `8085` |
| **Mailpit (UI)** | [http://myapp.local:8025](http://myapp.local:8025) | `8025` |
| **phpMyAdmin** | [http://myapp.local:8383](http://myapp.local:8383) | `8383` |
| **pgAdmin** | [http://myapp.local:8080](http://myapp.local:8080) | `8080` |
| **Redis Insight** | [http://myapp.local:5540](http://myapp.local:5540) | `5540` |

---

Developed with ❤️ to streamline local deployment. Happy coding! 🚀