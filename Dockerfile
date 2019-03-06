#FROM php:7.2-fpm
#WORKDIR /tmp
#RUN apt-get update && apt-get install -y \
#        libfreetype6-dev \
#        libjpeg62-turbo-dev \
#        libmcrypt-dev \
#        libpng-dev \
#        libxml2-dev \
#        libmemcached-dev \
#        libcurl4-openssl-dev \
#        --no-install-recommends \
#     && curl -OJL https://github.com/websupport-sk/pecl-memcache/archive/4a9e4ab0d12150805feca3012854de9fd4e5a721.tar.gz \
#     && tar xfz pecl-memcache-4a9e4ab0d12150805feca3012854de9fd4e5a721.tar.gz \
#     && cd pecl-memcache-4a9e4ab0d12150805feca3012854de9fd4e5a721 \
#     && phpize \
#     && ./configure \
#     && make \
#     && make install
#COPY ./pecl-memcache-4a9e4ab0d12150805feca3012854de9fd4e5a721/modules/memcache.so ./artifacts

FROM php:7.2-fpm
COPY ./artifacts/docker-php-pecl-install /usr/local/bin/
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libxml2-dev \
        libmemcached-dev \
        libcurl4-openssl-dev \
        libzip-dev \
        zip \
        --no-install-recommends \
        && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql soap zip pcntl \
    && docker-php-pecl-install mongodb \
    && docker-php-pecl-install memcached \
    && docker-php-pecl-install redis \
    && docker-php-pecl-install xdebug \
    && curl -OJL https://github.com/websupport-sk/pecl-memcache/archive/4a9e4ab0d12150805feca3012854de9fd4e5a721.tar.gz \
    && tar xfz pecl-memcache-4a9e4ab0d12150805feca3012854de9fd4e5a721.tar.gz \
    && cd pecl-memcache-4a9e4ab0d12150805feca3012854de9fd4e5a721 \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/*

RUN  echo extension=memcache.so > /usr/local/etc/php/conf.d/memcache.ini
COPY ./artifacts/php.ini /usr/local/etc/php
COPY ./artifacts/zzzz-custom.ini /usr/local/etc/php/conf.d
COPY ./artifacts/xdebug.ini /tmp
RUN  cat /tmp/xdebug.ini >> /usr/local/etc/php/conf.d/docker-php-pecl-xdebug.ini && rm -rf /tmp/xdebug.ini

RUN rm -rf /var/log/application && mkdir /var/log/application && chown www-data:www-data /var/log/application
RUN rm -rf /var/log/php && mkdir /var/log/php && chown www-data:www-data /var/log/php
RUN rm -rf /var/www/application/*

WORKDIR /var/www/application

EXPOSE 9000
CMD ["php-fpm"]
