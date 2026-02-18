FROM php:8.4-fpm

ARG USER
ARG USER_UID
ARG USER_GID
ARG APPLICATION_FOLDER

RUN if [ ! -d "./$APPLICATION_FOLDER" ]; then \
  echo "-----------------------------------------------------------------------"; \
  echo "❌ ERROR: The application folder does not exists"; \
  echo "Actual path to serve: ./$APPLICATION_FOLDER"; \
  echo "Please, create your laravel project or define the APPLICATION_FOLDER on .env"; \
  echo "-----------------------------------------------------------------------"; \
  exit 1; \
  fi

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN install-php-extensions gd xdebug pdo_mysql pdo_pgsql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY ./images/php/php.ini /usr/local/etc/php/conf.d/custom.ini

RUN useradd -u $USER_UID -ms /bin/bash -g www-data $USER

COPY --chown=$USER:www-data ./$APPLICATION_FOLDER /var/www

USER $USER
WORKDIR /var/www

EXPOSE 9000

CMD ["php-fpm"]