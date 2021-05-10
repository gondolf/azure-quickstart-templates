#!/bin/bash
	
# Partition the drive /dev/sdc.
# Read from standard input provide the options we want.
#  n adds a new partition.
#  p specifies the primary partition type.
#  the following blank line accepts the default partition number.
#  the following blank line accepts the default start sector.
#  the following blank line accepts the default final sector.
#  p prints the partition table.
#  w writes the changes and exits.
echo -e "nn\np\n1\n\n\nw" | fdisk /dev/sdd

# Creación del VG_Group
pvcreate /dev/sdd1
vgcreate vg_app /dev/sdd1

# Creación de los LVM
lvcreate -l 100%FREE -n lv_apache vg_app

# Formateo de volumenes
mkfs.ext4  /dev/mapper/vg_app-lv_apache

# Creaa carpeta y monta el volumen
mkdir /var/www
mount /dev/mapper/vg_app-lv_apache /var/www

# Agregar montado de disco al archivo /etc/fstab
echo '/dev/mapper/vg_app-lv_apache /var/www       ext4   defaults,nofail    1  2' >> /etc/fstab

# Inicia la instalación del subsistema
# Instalación de subsistema: Apache2
dpkg --configure -a
apt-get -y update

# install Apache2
apt-get -y install apache2

# write some HTML
vmmetadata="curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-04-02""
echo "<center><h1> Computer: $(hostname) </h1><br/>$($vmmetadata)</center>" > /var/www/html/index.html
# restart Apache
apachectl restart
