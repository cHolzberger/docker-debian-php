# Custom Debian image

Customized version of the debian base image. 
Removes systemd and udev and adds them to the ignore list.

Does not install documentation of packages. 

## Selections

This images provides an easy way to add packages to a derived image 
create a dir /selections add place a file inside this dir e.g. `yourPackages` 
which looks like:
`git install
zsh install`

then call `RUN set-selections yourPackages` inside your derived Dockerfile. 

## apt and dpkg preferences

place apt settings in `config/apt` and dpkg preferences in `config/dpkg` the will be included in the new image automaticaly. 

## confd
Including confd.
See: https://github.com/kelseyhightower/confd/blob/master/docs/quick-start-guide.md

## entrypoint commands

this image contains some predefined commands:

### init
you can init this container using the entrypoint "init" it will run /docker/container_init.d scripts using run-parts.

## Periodic tasks
all tasks in /docker/periodic_hourly.d and /docker/periodic_daily.d will be run. 
they should be executable and will be run unsing run-parts.

http://manpages.ubuntu.com/manpages/trusty/de/man8/run-parts.8.html

### Example

Integration daily script: 
```
echo "run/whatever" >> /srv/runme.sh 
chmod a+x /srv/runme.sh

docker run -v /srv/runme.sh /docker/periodic_daily.d/runme.sh
```

## Shrinking

This image has been flatened running `docker run --name debian mosaiksoftware/debian:onbuild && docker export debian | docker import - mosaiksoftware/debian:latest` which reduces its size to 43 MB.

However we lose ONBUILD capabilities doing so. 

Add this to your dockerfile if you dont use `:onbuild` : 
`COPY selections /selections/
COPY config/etc /etc`
