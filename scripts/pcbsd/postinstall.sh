#!/bin/sh -x

ntpdate -v -b in.pool.ntp.org

date > /etc/vagrant_box_build_time

env ASSUME_ALWAYS_YES=1 pkg bootstrap
pkg update
pkg install -y sudo
pkg install -y curl
pkg install -y ca_root_nss

# Emulate the ETCSYMLINK behavior of ca_root_nss; this is for FreeBSD 10, where fetch(1) was
# massively refactored and doesn't come with SSL CAcerts anymore
ln -sf /usr/local/share/certs/ca-root-nss.crt /etc/ssl/cert.pem

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
fetch -am -o authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# As sharedfolders are not in defaults ports tree
# We will use vagrant via NFS
# Enable NFS
echo 'rpcbind_enable="YES"' >> /etc/rc.conf
echo 'nfs_server_enable="YES"' >> /etc/rc.conf
echo 'mountd_flags="-r"' >> /etc/rc.conf

# Enable passwordless sudo
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers

# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
WITHOUT_X11="YES"
EOT

pw groupadd vboxusers
pw groupmod vboxusers -m vagrant

echo "=============================================================================="
echo "NOTE: FreeBSD - Vagrant"
echo "When using this basebox you need to do some special stuff in your Vagrantfile"
echo "1) Enable HostOnly network"
echo "	 config.vm.network ...."
echo "2) Use nfs instead of shared folders"
echo '		config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)'
echo "============================================================================="

exit
