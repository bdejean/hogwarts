# Dockerfile for web server image

FROM jacksoncage/apache:latest

# Install git, mysql, curl and composer
RUN apt-get update && \
    apt-get install git curl -y && \
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clone repo and set document root to it
RUN cd /var/www \
    && git clone https://github.com/Hugal31/hogwarts.git \
    && cd hogwarts \
    && composer install \
    && chown www-data storage/logs
ENV APACHE_DOCUMENTROOT=/var/www/hogwarts

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
RUN apt-get install -y vim
RUN apt-get clean

# Note : the mysql database is sometime long to init
ADD docker/wait-for-it.sh /usr/local/bin/
ADD docker/start.sh /
