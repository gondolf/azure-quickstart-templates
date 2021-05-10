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
# echo -e "n\np\n1\n\n\nw" | fdisk $devicePath

devicePath=/dev/sdd
vgName=vg_app
lvName=lv_apache
mountTarget=/var/www

# Creación del VG_Group
pvcreate $devicePath
vgcreate $vgName $devicePath

# Creación de los LVM
lvcreate -l 100%FREE -n $lvName $vgName

# Formateo de volumenes
mkfs.ext4  /dev/mapper/$vgName-$lvName

# Creaa carpeta y monta el volumen
mkdir $mountTarget
mount /dev/mapper/$vgName-$lvName $mountTarget

# Agregar montado de disco al archivo /etc/fstab
echo '/dev/mapper/$vgName-$lvName $mountTarget      ext4   defaults,nofail    1  2' >> /etc/fstab

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
