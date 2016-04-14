cd /phpfarm
git pull

cd /phpfarm/src
./compile.sh $PHP_VERSION 

tar cf /pkg/phpfarm-$PHP_VERSION.tar /phpfarm/inst
