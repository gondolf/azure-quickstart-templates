#!/bin/bash
dpkg --configure -a
apt-get -y update

# install Apache2
apt-get -y install apache2
# apt-get -y install mysql-server
# apt-get -y install php libapache2-mod-php php-mysql
# write some HTML
vmmetadata="curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-04-02""
echo "<center><h1> Computer: $(hostname) </h1><br/>$($vmmetadata)</center>" > /var/www/html/index.html
# restart Apache
apachectl restart
