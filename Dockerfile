FROM php:7.2-fpm
WORKDIR /tmp

# Install some required software
RUN  apt-get update && apt-get install -y --no-install-recommends \
     libfreetype6-dev \
     libjpeg62-turbo-dev \
     libmcrypt-dev \
     libpng-dev \
     libxml2-dev \
     libmemcached-dev \
     libcurl4-openssl-dev \
     libzip-dev \
     zip \
  && rm -r /var/lib/apt/lists/*

# PHP Plugins
COPY ./artifacts/docker-php-pecl-install /usr/local/bin/
RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-install -j$(nproc) gd pdo_mysql soap zip pcntl
RUN docker-php-pecl-install mongodb
RUN docker-php-pecl-install memcached
RUN docker-php-pecl-install redis
RUN docker-php-pecl-install xdebug

# pecl-memcache plugin
RUN  curl -OJL https://github.com/websupport-sk/pecl-memcache/archive/4a9e4ab0d12150805feca3012854de9fd4e5a721.tar.gz \
  && tar xfz pecl-memcache-4a9e4ab0d12150805feca3012854de9fd4e5a721.tar.gz \
  && cd pecl-memcache-4a9e4ab0d12150805feca3012854de9fd4e5a721 \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && echo extension=memcache.so > /usr/local/etc/php/conf.d/memcache.ini \
  && rm -rf /tmp/*

# Custom PHP settings for development
COPY ./artifacts/php.ini /usr/local/etc/php
COPY ./artifacts/zzzz-custom.ini /usr/local/etc/php/conf.d
COPY ./artifacts/xdebug.ini /tmp
RUN  cat /tmp/xdebug.ini >> /usr/local/etc/php/conf.d/docker-php-pecl-xdebug.ini && rm -rf /tmp/xdebug.ini

# Create PHP Logging folder
RUN  rm -rf /var/log/php \
  && mkdir /var/log/php \
  && chown www-data:www-data /var/log/php

# Useful volumes are the code and the logging directories
VOLUME ["/var/www/html", "/var/log/php"]

WORKDIR /var/www/html
EXPOSE 9000
CMD ["php-fpm"]
