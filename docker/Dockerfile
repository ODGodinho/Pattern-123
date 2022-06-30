FROM php:8.1-fpm-alpine

# Args
ARG SSH_PRIVATE_KEY
ARG NEW_RELIC_LICENSE_KEY
ARG NEW_RELIC_APP_NAME
ARG GITHUB_ACCESS_TOKEN

WORKDIR /var/www/html/project

# Install NGINX
RUN apk update \
    && apk upgrade \
    && apk add nginx supervisor wget libc6-compat

COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /usr/share/nginx/www
RUN mkdir -p /run/nginx

# Install supervisord
COPY ./docker/supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Config php-fpm
COPY ./docker/php-fpm/www.conf /usr/local/etc/php-fpm.d/www.conf

# Install dependencies
RUN apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \ 
  libxml2-dev curl-dev linux-headers oniguruma-dev imap-dev openssl-dev git openssh-client

# Install extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql dom curl mbstring imap opcache

# Install redis php and enable
RUN pecl install redis \
  && docker-php-ext-enable redis

# Composer
RUN \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && HASH="$(wget -q -O - https://composer.github.io/installer.sig)" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# NewRelic
RUN mkdir -p /var/log/newrelic /var/run/newrelic /etc/default/ && \
    touch /var/log/newrelic/php_agent.log /var/log/newrelic/newrelic-daemon.log && \
    chmod -R g+ws /tmp /var/log/newrelic/ /var/run/newrelic/ && \
    chown -R 1001:0 /tmp /var/log/newrelic/ /var/run/newrelic/ && \
    wget -nd -r -l1 -np "https://download.newrelic.com/php_agent/release/" -P /tmp -A "newrelic-php5*-linux.tar.gz" && \
    cd /tmp && tar xvzf /tmp/newrelic-php5*-linux.tar.gz && \
    NR_INSTALL_SILENT=true /tmp/newrelic-php5*-linux/newrelic-install install && \
    rm -f /var/run/newrelic-daemon.pid && \
    rm -f /tmp/.newrelic.sock && \
    cp /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2 && \
    sed -i \
        -e "s/newrelic.license =.*/newrelic.license = ${NEW_RELIC_LICENSE_KEY}/" \
        -e "s/newrelic.appname =.*/newrelic.appname = ${NEW_RELIC_APP_NAME}/" \
        /usr/local/etc/php/conf.d/newrelic.ini

# Copy files
COPY source/ /var/www/html/project

# SSH Config
RUN composer config -g github-oauth.github.com "$GITHUB_ACCESS_TOKEN"

# Install dependencies
RUN composer install --no-dev

# Setting permissions
RUN \
    chown -R www-data:www-data /var/www/html/project && \
    find /var/www/html/project -type f -exec chmod 644 {} \; && \
    find /var/www/html/project -type d -exec chmod 755 {} \;

EXPOSE 80 443

# Remove Build Dependencies
RUN apk del -f $PHPIZE_DEPS libxml2-dev curl-dev linux-headers oniguruma-dev imap-dev openssl-dev wget

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
