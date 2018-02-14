#!/bin/bash

mydir=$(dirname "$0")
cd "$mydir"

diff daemon.json /etc/docker/daemon.json || (cp daemon.json /etc/docker/daemon.json && systemctl restart docker)

docker volume create --name contrail-dev-env-rpms
docker run --name contrail-dev-env-rpm-repo -d -v contrail-dev-env-rpm-volume:/var/www/localhost/htdocs -p 6667:80 sebp/lighttpd || docker start contrail-dev-env-rpm-repo
docker run --name contrail-dev-env-registry -d -p 6666:5000 registry:2 || docker start contrail-dev-env-registry
docker run --name contrail-developer-sandbox -w /root -td -v /var/run/docker.sock:/var/run/docker.sock -v contrail-dev-env-rpm-volume:/root/rpmbuild/RPMS -v $(pwd):/root/contrail-dev-env opencontrail/developer-sandbox:centos-7.4 || docker start contrail-developer-sandbox

echo "You can now connect to the sandbox container by using: $ docker attach contrail-developer-sandbox"
