# Vagrant for OpenInfoMan

This an in-progress creation of a base box for end-to-end testing of OpenInfoMan using Vagrant and Ansible. It is not complete.

The CentOS version is copied and modified from the BAO Systems DHIS2-CentOS [Vagrantfile](https://github.com/baosystems/dhis2-centos).


## Troubleshooting

* For cleaning up, note that Vagrant boxes are stored in `~/.vagrant.d/boxes`.
* [macOS] If there is a port conflict error for ssh, then clear out port forwarding entry for 2222 in /Library/Preferences/VMware fusion/networking and /Library/Preferences/VMware fusion/vmnet8/nat.conf