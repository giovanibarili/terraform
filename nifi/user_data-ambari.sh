#! /bin/bash  -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

rpm -Uvh http://public-repo-1.hortonworks.com/HDP-1.0.1.14/repos/centos6/hdp-release-1.0.1.14-1.el6.noarch.rpm
yum install epel-release
yum install ambari-1.0.0-1.el6.noarch.rpm
yum install hdp_mon_dashboard-0.0.2.14-1.noarch.rpm