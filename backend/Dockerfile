FROM php:8.4-cli-alpine

RUN apk add --no-cache \
        git \
        unzip \
        libpq-dev \
        postgresql-dev \
        oniguruma-dev \
        icu-dev \
        libzip-dev \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring intl zip bcmath \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app

EXPOSE 8000

CMD ["sh", "-c", "if [ -f composer.json ] && [ ! -d vendor ]; then composer install --no-interaction; fi && php artisan serve --host=0.0.0.0 --port=8000"]
