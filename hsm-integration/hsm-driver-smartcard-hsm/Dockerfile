FROM keyfactor/ejbca-ce AS builder

WORKDIR /build

USER 0:0

# First use microdnf to install yum and its dependencies
RUN microdnf -y update && \
    microdnf -y install yum yum-utils epel-release && \
    # Enable additional repositories for AlmaLinux
    yum -y install dnf-plugins-core && \
    yum -y config-manager --set-enabled almalinux-powertools && \
    yum update && \
    # Now use yum for the rest of the installations
    yum -y groupinstall "Development Tools" && \
    yum -y install openssl-devel automake autoconf libtool pkgconfig pcsc-lite-devel && \
    curl --silent -D - -L "https://github.com/CardContact/sc-hsm-embedded/archive/refs/heads/master.zip" -o sc-hsm-pkcs11.zip && \
    unzip sc-hsm-pkcs11.zip && \
    cd sc-hsm-embedded-master && \
    autoreconf -fis && \
    ./configure --prefix=/usr && \
    make -s && \
    make -s install

FROM keyfactor/ejbca-ce:latest


COPY --from=builder --chown=10001:0  /usr/lib64/libsc-hsm-pkcs11.so     /usr/lib64/pkcs11/libsc-hsm-pkcs11.so
COPY sc-hsm.conf /etc/pkcs11/modules/sc-hsm.conf

# Install USBIP tools and kernel modules
RUN microdnf -y update && \
    microdnf -y install epel-release && \
    microdnf -y install pcsc-lite-libs \
    kernel-modules-extra \
    usbip-utils \
    kmod && \
    # Load USBIP modules
    echo "usbip-core" >> /etc/modules-load.d/usbip.conf && \
    echo "usbip-host" >> /etc/modules-load.d/usbip.conf && \
    echo "vhci-hcd" >> /etc/modules-load.d/usbip.conf && \
    # Create module dependencies
    depmod -a && \
    # Download VirtualHere USB Client
    curl -sSL https://www.virtualhere.com/sites/default/files/usbclient/vhclientx86_64 -o /usr/local/bin/vhuit64 && \
    chmod +x /usr/local/bin/vhuit64 && \
    # Create startup script
    echo '#!/bin/bash\n\
    # Load required kernel modules\n\
    modprobe usbip-core\n\
    modprobe usbip-host\n\
    modprobe vhci-hcd\n\
    # Start VirtualHere client\n\
    /usr/local/bin/vhuit64 -n' > /usr/local/bin/start-vh-client && \
    chmod +x /usr/local/bin/start-vh-client

# Create directory for VirtualHere configuration if needed
RUN mkdir -p /etc/virtualhere && \
    chown 10001:0 /etc/virtualhere

USER 10001:0

# Add an entrypoint script that starts VirtualHere client daemon
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
