FROM ubuntu:20.04

RUN apt update -y && \
    apt install -y gcc vim python3 python3-pip curl libwww-perl libjson-perl libyaml-dev ethtool && pip3 install xq && \
    curl -C - -O "https://s3.amazonaws.com/files.molo.ch/builds/ubuntu-20.04/arkime_3.3.0-1_amd64.deb" && \
    dpkg -i arkime_3.3.0-1_amd64.deb || true && \
    apt-get install -yqf
    # Pull maxmind Geo info for countries
RUN curl -L -o /tmp/GeoLite2-Country.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=GDqrbhx8P5vE&suffix=tar.gz" && \
    # Pull maxmind Geo info for ASNs
    curl -L -o /tmp/GeoLite2-ASN.tar.gz "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=GDqrbhx8P5vE&suffix=tar.gz" && \
    curl -L -o /opt/arkime/etc/ipv4-address-space.csv "https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.csv" && \
    curl -L -o /opt/arkime/etc/oui.txt "https://raw.githubusercontent.com/wireshark/wireshark/master/manuf" && \
    # Modify SMB parser to add additional fields from smb.lua
    echo '    +arrayList(session.smb, "opcode", "OpCode", "smb.opcode")' >> /opt/arkime/parsers/smb.detail.jade && \
    echo '    +arrayList(session.smb, "cmd", "Command", "smb.cmd")' >> /opt/arkime/parsers/smb.detail.jade && \
    # Create file to test if it has been started before
    echo "0" > /init.txt && \
    # Create tags folder
    mkdir /opt/arkime/tags/

RUN tar -ztf /tmp/GeoLite2-Country.tar.gz | grep mmdb | xargs -I X tar -Ozxf /tmp/GeoLite2-Country.tar.gz X >> /opt/arkime/etc/GeoLite2-Country.mmdb && \
    tar -ztf /tmp/GeoLite2-ASN.tar.gz | grep mmdb | xargs -I X tar -Ozxf /tmp/GeoLite2-ASN.tar.gz X >> /opt/arkime/etc/GeoLite2-ASN.mmdb && \
    rm -rf /tmp/GeoLite2-*

# Copy lua script parsers
COPY lua/dcerpc.lua /opt/arkime/lua/dcerpc.lua
COPY lua/smb.lua /opt/arkime/lua/smb.lua
COPY lua/entropy.lua /opt/arkime/lua/entropy.lua

# Copy wise dependencies
#COPY wise/source.majestic.js /opt/arkime/wiseService/source.majestic.js
COPY wise/wiseService.ini /opt/arkime/etc/wiseService.ini

# Copy arkime's config file
COPY config/config.ini /opt/arkime/etc/config.ini

# Copy start script to /data/startmoloch.sh
COPY entrypoint/startarkime.sh /opt/arkime/startarkime.sh
RUN chmod +x /opt/arkime/startarkime.sh

WORKDIR /opt/arkime/viewer
CMD /bin/bash

# Runs this script upon start of container
ENTRYPOINT ["/opt/arkime/startarkime.sh"]