FROM ghcr.io/home-assistant/base-debian:latest

# Add env
ENV LANG=C.UTF-8

# Set CUPS environment variables for data persistence (HA shared directory)
ENV CUPS_DATADIR=/share/cups
ENV CUPS_CACHEDIR=/share/cups/cache
ENV CUPS_LOGDIR=/share/cups/logs
ENV CUPS_STATEDIR=/share/cups/state
ENV CUPS_SERVERROOT=/share/cups/config

# First update
RUN apt update

# Add Samsung Unified
RUN \
    bash -c 'echo "deb https://www.bchemnet.com/suldr/ debian extra" >> /etc/apt/sources.list' && \
    curl https://www.bchemnet.com/suldr/pool/debian/extra/su/suldr-keyring_4_all.deb -o "/tmp/keyring.deb" \
        && apt install -y "/tmp/keyring.deb" && rm -f "/tmp/keyring.deb"

# Install all the things
RUN \
    apt update && \
    apt install -y suldr-keyring && \
    apt install -y \
        printer-driver-all cups-filters cups-ppdc bluez-cups cups cups-bsd hplip \
        openprinting-ppds scdaemon rng-tools gpm gutenprint-locales hpijs-ppds \
        magicfilter psutils avahi-autoipd \
        suld-driver2-1.00.39 suld-ppd-4 suld-driver2-common-1


# Copy data
COPY rootfs /

# Expose CUPS web interface port
EXPOSE 631

HEALTHCHECK \
    CMD lpstat -r || exit 1
