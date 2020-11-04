# Install Moodle with PHP
FROM marketplace.gcr.io/google/php7-apache2:7.3

# Define working directory
WORKDIR /var/www/html

# Install updates
RUN apt-get update -y && apt-get upgrade -y

RUN set -ex; \
    apt-get install curl -y; \
    curl -L -o moodle.tar.gz https://github.com/moodle/moodle/archive/v3.9.2.tar.gz; \
    tar xzfv moodle.tar.gz;

RUN chown -R www-data:www-data /var/www/html/

RUN set -ex; \
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
        apt-transport-https \
		gettext gnupg libcurl4-openssl-dev libfreetype6-dev libicu-dev libjpeg62-turbo-dev \
        libldap2-dev libmariadbclient-dev libmemcached-dev libpng-dev libpq-dev libxml2-dev libxslt-dev \
        unixodbc-dev uuid-dev \
        libpq5 \
        ghostscript libaio1 libgss3 libmcrypt-dev libxml2 libxslt1.1 \
        libzip-dev locales sassc unixodbc unzip zip \
        libmemcached11 libmemcachedutil2 \
        libldap-2.4-2 \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype-dir=/usr \
		--with-jpeg-dir=/usr \
		--with-png-dir=/usr \
	; \
	\
	docker-php-ext-install -j "$(nproc)" \
		gd \
		intl \
                mysqli \
                opcache \
                pgsql \
                soap \
                xsl \
                xmlrpc \
	;
 
# LDAP.
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install -j$(nproc) ldap
 
RUN pecl install memcached mongodb redis apcu igbinary solr uuid && \
    docker-php-ext-enable memcached mongodb redis apcu igbinary solr uuid
 
# ZIP
RUN docker-php-ext-configure zip --with-libzip && docker-php-ext-install zip
 
RUN echo 'apc.enable_cli = On' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini
 
RUN a2enmod rewrite expires
  
# Download package and extract to web volume
RUN set -eux; \
	curl -fSL "https://github.com/moodle/moodle/archive/v3.9.2.tar.gz" -o moodle.tar.gz; \
	tar -xz --strip-components=1 -f moodle.tar.gz; \
	rm moodle.tar.gz
 
ENV COMPOSER_VERSION 1.9.1
ENV COMPOSER_SHA256 1f210b9037fcf82670d75892dfc44400f13fe9ada7af9e787f93e50e3b764111
 
# Install composer binary and install drush
RUN set -eux; \
	apt-get update && apt-get install -y --no-install-recommends git unzip; \
	curl -o composer.phar "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar"; \
	chmod +x composer.phar; \
	rm -f composer.phar; \
	rm -rf /var/lib/apt/lists/*
 
VOLUME /var/www/html
 
# Copy init scripts
#COPY docker-entrypoint.sh /entrypoint.sh 
#RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
