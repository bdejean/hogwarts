# Dockerfile for web server image

FROM jacksoncage/apache:latest

ENV DEBIAN_FRONTEND noninteractive

# Install git, mysql, curl and composer
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y git curl vim-tiny php5-sqlite && \
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV APACHE_DOCUMENTROOT=/var/www/hogwarts

# Copy repo and install composer
# git ls-files | awk -F'/' '!u[$1]++ { print $1 }' | egrep -iv 'docker|.git|.env.example|README.md' | sort | while read D; do S=$D; [ -d $D ] && S="$S/"; printf 'COPY %s ${APACHE_DOCUMENTROOT}/%s\n' $S $D; done | column -t
COPY  app/           ${APACHE_DOCUMENTROOT}/app
COPY  artisan        ${APACHE_DOCUMENTROOT}/artisan
COPY  bootstrap/     ${APACHE_DOCUMENTROOT}/bootstrap
COPY  composer.json  ${APACHE_DOCUMENTROOT}/composer.json
COPY  composer.lock  ${APACHE_DOCUMENTROOT}/composer.lock
COPY  database/      ${APACHE_DOCUMENTROOT}/database
COPY  .htaccess      ${APACHE_DOCUMENTROOT}/.htaccess
COPY  phpunit.xml    ${APACHE_DOCUMENTROOT}/phpunit.xml
COPY  public/        ${APACHE_DOCUMENTROOT}/public
COPY  resources/     ${APACHE_DOCUMENTROOT}/resources
COPY  storage/       ${APACHE_DOCUMENTROOT}/storage
COPY  tests/         ${APACHE_DOCUMENTROOT}/tests

RUN chown -R www-data ${APACHE_DOCUMENTROOT}

USER www-data
ENV COMPOSER_CACHE_DIR /tmp/composer_cache_dir
RUN mkdir $COMPOSER_CACHE_DIR
RUN cd ${APACHE_DOCUMENTROOT} \
    && composer install
RUN rm -rf $COMPOSER_CACHE_DIR

USER root
run chown -R root ${APACHE_DOCUMENTROOT}
RUN chmod -R a+rX ${APACHE_DOCUMENTROOT}
RUN chown www-data ${APACHE_DOCUMENTROOT}/storage/logs

RUN mkdir -m 1777 /var/lib/db

# Lumen arguments
# Don't forget to give APP_KEY and DB_HOST

ENV APP_ENV=prod \
    APP_DEBUG=false \
    APP_KEY= \
    DB_CONNECTION=sqlite \
    CACHE_DRIVER=array \
    QUEUE_DRIVER=array \
    SEED_DATABASE=false

RUN a2dissite 000-default.conf 001-docker.conf

COPY docker/042-hogwarts.conf /etc/apache2/sites-available/
COPY keys/hogwarts.* /etc/apache2/ssl/
RUN a2enmod ssl
RUN a2ensite 042-hogwarts.conf

RUN apt-get autoremove
RUN apt-get clean

# Inherit from /apache for start.
