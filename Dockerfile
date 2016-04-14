FROM mosaiksoftware/debian
#
# PHP Farm Docker image
#

MAINTAINER Christian Holzberger, ch@mosaiksoftware.de

ENV PHP_VERSION 5.5.34
ENV PHPMYADMIN_VERSION 4.6.0

COPY config /etc
COPY selections /selections

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
			set-selections smtp && \
		end-apt

#freetype build fix
RUN mkdir /usr/include/freetype2/freetype/ && ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h

# install and run the phpfarm script
# compile, then delete sources (saves space)

COPY pkg/phpfarm-$PHP_VERSION.tar /
RUN tar xf /phpfarm-$PHP_VERSION.tar && rm /phpfarm-$PHP_VERSION.tar
#set short_open_tag
RUN sed -e "s/short_open_tag = Off/short_open_tag = On/g" -i /phpfarm/inst/php-*/lib/php.ini
RUN sed -e "s/error_log = syslog/error_log = \/var\/log\/php.log/g" -i /phpfarm/inst/php-*/lib/php.ini

RUN touch /var/log/php.log && chmod a+rw /var/log/php.log

#copy default config
RUN cp /phpfarm/inst/php-${PHP_VERSION}/lib/php.ini /etc/php/${PHP_VERSION}/

# reconfigure Apache
RUN rm -rf /var/www/*

COPY var-www /var/www/

RUN a2enmod rewrite proxy proxy_fcgi
RUN a2enmod remoteip
RUN a2dissite 000-default
RUN mkdir /etc/php/conf.d /etc/php/fpm.d

# set path
ENV PATH /phpfarm/inst/bin/:/usr/sbin:/usr/bin:/sbin:/bin

# expose the ports
EXPOSE 80

# run it
COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
