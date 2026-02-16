FROM php:8.3-fpm

ARG user
ARG uid

RUN apk add --update --no-cache --virtual .build-deps \
  autoconf \
  nodejs \
  npm \
  automake \
  g++ \
  bash \
  gcc \
  make \
  libzip-dev \
  libpng-dev \
  libonig-dev \
  libxml2-dev \
  zip \
  unzip \
  postgresql-dev \
  postgresql-libs \
  sqlite-dev \
  mysql-client \
  git \
  curl

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-configure intl

RUN docker-php-ext-install bcmath gd opcache zip intl pdo pdo_mysql mysqli pdo_pgsql pdo_sqlite pcntl mbstring exif
RUN docker-php-ext-enable opcache

# (Optional)
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -u $uid -ms /bin/bash -g www-data $user

COPY . /var/www
COPY --chown=$user:www-data . /var/www

USER $user

EXPOSE 9000

CMD ["php-fpm"]