FROM composer:latest AS composer

FROM php:7.4-fpm-alpine

# Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Add supercronic
ADD https://github.com/aptible/supercronic/releases/download/v0.1.12/supercronic-linux-amd64 /tmp/supercronic
RUN mv /tmp/supercronic /usr/local/bin/supercronic \
  && chmod a+x /usr/local/bin/supercronic

# Add the S6 overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C / \
  && rm /tmp/s6-overlay-amd64.tar.gz

# Add the local php security checker
ADD https://github.com/fabpot/local-php-security-checker/releases/download/v1.0.0/local-php-security-checker_1.0.0_linux_amd64 /tmp/local-php-security-checker
RUN mv /tmp/local-php-security-checker /usr/local/bin/local-php-security-checker \
  && chmod a+x /usr/local/bin/local-php-security-checker

# Apply overlay files
ADD root /

RUN apk --update upgrade && \
  apk add \
  bash \
  freetype \
  git \
  icu-libs \
  libwebp \
  libjpeg-turbo \
  libpng \
  libzip \
  mysql-client \
  netcat-openbsd \
  nginx \
  sudo \
&& rm -rf /var/cache/apk/*

# Add/compile useful extensions - note that xdebug should NOT be enabled by default
RUN docker-php-source extract \
  && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS zlib-dev icu-dev pcre-dev libzip-dev freetype-dev libwebp-dev libjpeg-turbo-dev libpng-dev \
  && pecl install apcu redis xdebug \
  && docker-php-ext-enable apcu redis \
  && docker-php-ext-install intl bcmath gd pdo_mysql opcache zip \
  && apk del .phpize-deps \
  && docker-php-source delete \
  && rm -fr /tmp/pear/cache

ENTRYPOINT ["/init"]
