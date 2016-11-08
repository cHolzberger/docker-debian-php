FROM mosaiksoftware/debian
#
# PHP Farm Docker image
#

MAINTAINER Christian Holzberger, ch@mosaiksoftware.de

COPY config /etc
COPY selections /selections

# copy payload
COPY var-www /var/www/

# set path
ENV PATH /phpfarm/inst/bin/:/usr/sbin:/usr/bin:/sbin:/bin

# expose the ports
EXPOSE 80

# run it
COPY run.sh /run.sh

EXPOSE 80
ENTRYPOINT [ "/bin/dinit","-r","/bin/docker-entrypoint" ]
CMD ["bash","/run.sh"]
