FROM php:7.1-apache

RUN apt-get update && apt-get install -y git-core cron \
  libjpeg-dev libmcrypt-dev libpng-dev libpq-dev \
  libjpeg62-turbo-dev apt-transport-https \
  libfreetype6-dev libssl-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-freetype-dir --with-jpeg-dir --enable-gd \
  && docker-php-ext-install -j$(nproc) gd mcrypt mysqli opcache pdo pdo_mysql zip

 RUN docker-php-ext-enable gd

# Recommended opcache settings - https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/docker-ci-opcache.ini

RUN { \
    echo 'log_errors=on'; \
    echo 'display_errors=off'; \
    echo 'upload_max_filesize=32M'; \
    echo 'post_max_size=32M'; \
    echo 'memory_limit=128M'; \
    echo 'date.timezone="UTC"'; \
  } > /usr/local/etc/php/conf.d/docker-ci-php.ini

RUN { \
    echo '<FilesMatch "^\.">'; \
    echo '    Order allow,deny'; \
    echo '    Deny from all'; \
    echo '</FilesMatch>'; \
    echo '<DirectoryMatch "^\.|\/\.">'; \
    echo '    Order allow,deny'; \
    echo '    Deny from all'; \
    echo '</DirectoryMatch>'; \
  } > /etc/apache2/conf-available/docker-ci-php.conf

RUN a2enconf docker-ci-php

RUN a2enmod rewrite

#COPY --chown=www-data:www-data ./CodeIgniter_1.7.3 /usr/src/CodeIgniter_1.7.3

#RUN ln -s /usr/src/CodeIgniter_1.7.3/system /var/www/codeigniter

#COPY docker-entrypoint /usr/local/bin/

#ENTRYPOINT ["docker-entrypoint"]
CMD ["apache2-foreground"]