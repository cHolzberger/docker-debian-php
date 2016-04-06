FROM mosaiksoftware/debian:onbuild
#
# PHP Farm Docker image
#

MAINTAINER Christian Holzberger, ch@mosaiksoftware.de

ENV PHP_VERSION 5.5.34
ENV PHPMYADMIN_VERSION 4.6.0

# add hhvm key
ENV DEBIAN_FRONTEND noninteractive
# make php 5.3 work again
ENV LDFLAGS "-lssl -lcrypto"
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
# add some build tools
RUN begin-apt && \
			apt-get install -y ca-certificates && \
    	set-selections phpfarm-basic && \
			set-selections phpfarm-dev && \
			apt-get build-dep -y php5 && \
		end-apt

# wkhtmltopdf offical binary
COPY /pkg/ /tmp/
RUN dpkg -i /tmp/wkhtmltox-0.13.0-alpha-7b36694_linux-jessie-amd64.deb && rm /tmp/wkhtmltox-0.13.0-alpha-7b36694_linux-jessie-amd64.deb

RUN wget https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.tar.gz -O /tmp/phpmyadmin.tar.gz \
&& cd /opt \
&& tar xzf /tmp/phpmyadmin.tar.gz \
&& mv phpMyAdmin-$PHPMYADMIN_VERSION-all-languages phpmyadmin \
&& chown www-data:www-data /opt/phpmyadmin

COPY config/phpmyadmin /opt/phpmyadmin
#freetype build fix
RUN mkdir /usr/include/freetype2/freetype/ && ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h

# add customized configuration
COPY config/phpfarm /tmp/phpfarm
# install and run the phpfarm script
# compile, then delete sources (saves space)
RUN git clone https://github.com/cweiske/phpfarm.git phpfarm \
&& cp -r /tmp/phpfarm/* /phpfarm/src \
&& cd /phpfarm/src && \
    ./compile.sh $PHP_VERSION && \
    rm -rf /phpfarm/src && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#set short_open_tag
RUN sed -e "s/short_open_tag = Off/short_open_tag = On/g" -i /phpfarm/inst/php-*/lib/php.ini
RUN sed -e "s/error_log = syslog/error_log = \/var\/log\/php.log/g" -i /phpfarm/inst/php-*/lib/php.ini

RUN touch /var/log/php.log && chmod a+rw /var/log/php.log

#copy default config
RUN cp /phpfarm/inst/php-${PHP_VERSION}/lib/php.ini /etc/php/${PHP_VERSION}/

# reconfigure Apache
RUN rm -rf /var/www/*

COPY var-www /var/www/
COPY config/apache  /etc/apache2/

RUN apt-get remove -y mysql-server-5.5
RUN a2enmod rewrite proxy proxy_fcgi
RUN a2enconf phpfarm
RUN a2ensite php
RUN a2dissite 000-default

# set path
ENV PATH /phpfarm/inst/bin/:/usr/sbin:/usr/bin:/sbin:/bin

# expose the ports
EXPOSE 80

# run it
COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
