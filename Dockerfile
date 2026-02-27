FROM php:8.4-fpm

ARG USER
ARG USER_UID
ARG USER_GID
ARG APPLICATION_FOLDER

RUN apt-get update && apt-get install -y \
  curl \
  git \
  zip \
  unzip \
  supervisor \
  libicu-dev \
  ca-certificates \
  gnupg2 \
  htop \
  nano \
  default-mysql-client \
  vim \
  && apt-get autoremove -y && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /var/cache/apk/* /tmp/* /var/tmp/*

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN install-php-extensions gd mbstring exif pcntl bcmath zip xdebug pdo_mysql pdo_pgsql redis opcache
RUN docker-php-ext-enable opcache redis xdebug

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY ./images/php/php.ini /usr/local/etc/php/conf.d/custom.ini

RUN useradd -u $USER_UID -ms /bin/bash -g www-data $USER

COPY --chown=$USER:www-data ./$APPLICATION_FOLDER /var/www

RUN mkdir -p \
  storage/framework/{sessions,views,cache,testing} \
  storage/logs \
  bootstrap/cache \
  && chown -R ${USER_UID}:${USER_GID} /var/www

USER $USER
WORKDIR /var/www

EXPOSE 9000

CMD ["php-fpm"]