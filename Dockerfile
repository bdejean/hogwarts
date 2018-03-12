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
COPY . ${APACHE_DOCUMENTROOT}
RUN rm -rf ${APACHE_DOCUMENTROOT}/.git*
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

# Lumen arguments
# Don't forget to give APP_KEY and DB_HOST

ENV APP_ENV=prod \
    APP_DEBUG=false \
    APP_KEY= \
    DB_CONNECTION=mysql \
    DB_PORT=3306 \
    DB_DATABASE=hogwarts \
    DB_USERNAME=hogwarts \
    CACHE_DRIVER=array \
    QUEUE_DRIVER=array \
    SEED_DATABASE=false

RUN a2dissite 000-default.conf

RUN apt-get autoremove
RUN apt-get clean

# Note : the mysql database is sometime long to init
ADD docker/wait-for-it.sh /usr/local/bin/
ADD docker/start.sh /
