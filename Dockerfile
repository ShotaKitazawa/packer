FROM ubuntu:trusty

WORKDIR /srv

RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install kvm qemu-kvm libvirt-bin bridge-utils libguestfs-tools aria2 unzip dos2unix unrar-free wget git

ADD ./tmp/packer /usr/local/bin/

EXPOSE 5901

CMD /bin/bash
