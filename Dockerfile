FROM ubuntu:16.04

MAINTAINER "Thaweesak Chusri" <t.chusri@gmail.com>

# Upgrade
RUN apt-get update -y
RUN apt-get upgrade -y

# Install Nginx
RUN apt-get install -y nginx
RUN ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'

# Apply Nginx configuration
# ADD config/nginx.conf /opt/etc/nginx.conf
RUN rm /etc/nginx/sites-available/default
ADD config/laravel /etc/nginx/sites-available/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Nginx startup script
ADD config/nginx-start.sh /opt/bin/nginx-start.sh
RUN chmod u=rwx /opt/bin/nginx-start.sh

RUN mkdir -p /data
VOLUME ["/data"]

# Install PHP-FPM and popular/laravel required extensions
RUN apt-get install -y \
	zip \
	unzip \
	curl \
	git \
	php-fpm \
	php-mcrypt \
	php-mysql \
	php-mbstring \
	php-curl \
	php-gd \
	php-intl \
	php-pear \
	php-imagick \
	php-imap \
	php-memcache \
	php-pspell \
	php-recode \
	php-sqlite3 \
	php-tidy \
	php-xmlrpc \
	php-xsl \
	php-mbstring \
	php-gettext \
	vim \
	cron

# Configure PHP-FPM
RUN sed -i "s/\;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
# RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
# RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
# RUN echo "xdebug.max_nesting_level=500" > /etc/php5/mods-available/xdebug.ini
	# sed -i "s/display_errors = Off/display_errors = stderr/" /etc/php5/fpm/php.ini && \
	# sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/" /etc/php5/fpm/php.ini && \
	# sed -i "s/;opcache.enable=0/opcache.enable=0/" /etc/php5/fpm/php.ini && \
	# sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf && \
	# sed -i '/^listen = /clisten = 9000' /etc/php5/fpm/pool.d/www.conf && \
	# sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php5/fpm/pool.d/www.conf && \
	# sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php5/fpm/pool.d/www.conf && \
	# sed -i '/^;env\[TEMP\] = .*/aenv[DB_PORT_3306_TCP_ADDR] = $DB_PORT_3306_TCP_ADDR' /etc/php5/fpm/pool.d/www.conf

RUN phpenmod mcrypt
RUN phpenmod mbstring

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
RUN composer self-update

# Data Volume
# RUN mkdir -p /data/logs/ /data/www/
RUN mkdir -p /data/
RUN ls /data
VOLUME ["/data"]

# COPY config/php.ini /etc/php5/fpm/php.ini
COPY config/nginx.conf /etc/nginx/nginx.conf

# PORTS
EXPOSE 80
EXPOSE 443
EXPOSE 9000

WORKDIR /data

# ONBUILD COPY requirements.txt /usr/src/app/
# ONBUILD RUN pip install --no-cache-dir -r requirements.txt

# ONBUILD COPY . /usr/src/app
ENTRYPOINT ["/usr/sbin/php7.0-fpm", "-F"]
ENTRYPOINT ["/opt/bin/nginx-start.sh"]
