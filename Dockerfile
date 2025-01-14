FROM php:8.2.27-apache-bullseye

RUN apt-get update && apt-get install -y \
      zlib1g-dev \
      libicu-dev \
      libpq-dev \
      libmcrypt-dev \
      libpng-dev \
      wget \
      python-setuptools \
      xvfb \
      libfontconfig \
      wkhtmltopdf \
      libonig-dev \
      libzip-dev \
    && rm -r /var/lib/apt/lists/* \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install \
      bcmath \
      intl \
      mbstring \
      pcntl \
      pdo_mysql \
      zip \
      opcache \
      gd 

RUN pecl install redis-6.1.0 \
    && docker-php-ext-enable redis

RUN pecl install raphf-2.0.1 \
    && docker-php-ext-enable raphf

RUN apt-get update && apt-get install -y \
  libcurl4-openssl-dev libssl-dev

RUN pecl install pecl_http \
    && docker-php-ext-enable http

RUN apt-get update && apt-get install -y \
    libmagickwand-dev libmagickcore-dev

RUN pecl install imagick \
    && docker-php-ext-enable imagick

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN echo "ServerTokens Prod\n" >> /etc/apache2/apache2.conf
RUN echo "ServerSignature Off\n" >> /etc/apache2/apache2.conf
RUN echo "expose_php = off" >> /usr/local/etc/php/php.ini
RUN echo 'Header set X-XSS-Protection: "1; mode=block"'  >> /etc/apache2/apache2.conf
RUN echo "Header always append X-Frame-Options SAMEORIGIN" >> /etc/apache2/apache2.conf
RUN echo 'Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure' >> /etc/apache2/apache2.conf
RUN echo 'Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains;"' >> /etc/apache2/apache2.conf
RUN echo 'RewriteCond %{THE_REQUEST} ^POST(.*)HTTP/(0\.9|1\.0)$ [NC]' >> /etc/apache2/apache2.conf

RUN a2enmod rewrite
RUN a2enmod headers

RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
