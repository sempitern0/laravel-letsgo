FROM php:8.3-fpm

ARG USER
ARG USER_UID
ARG USER_GID

# RUN apt update && apt install -y --no-install-recommends \
#   zip \
#   unzip \
#   git \
#   curl \
#   autoconf \
#   nodejs \
#   npm \
#   automake \
#   g++ \
#   bash \
#   gcc \
#   make \
#   libzip-dev \
#   libpng-dev \
#   libonig-dev \
#   libxml2-dev \
#   libicu-dev \
#   libpq-dev \
#   libsqlite3-dev \
#   default-mysql-client \
#   default-mysql-client && apt-get clean && rm -rf /var/lib/apt/lists/*


# RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
# RUN docker-php-ext-configure intl
# RUN docker-php-ext-install bcmath gd opcache zip intl pdo pdo_mysql mysqli pdo_pgsql pdo_sqlite pcntl mbstring exif
# RUN docker-php-ext-enable opcache

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN install-php-extensions gd xdebug

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY ./images/php/php.ini /usr/local/etc/php/conf.d/custom.ini

RUN useradd -u $USER_UID -ms /bin/bash -g www-data $USER

COPY . /var/www
COPY --chown=$USER:www-data . /var/www

USER $USER
WORKDIR /var/www

EXPOSE 9000

CMD ["php-fpm"]