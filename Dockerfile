# hadolint global ignore=DL3003,DL3006,SC1035,DL4006,DL3008,SC2174,DL3015
FROM debian:12

ENV HOME=/root
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# ignore: DL4006
RUN dpkg --add-architecture i386 && apt-get update && apt-get -y install unzip xz-utils python3 python-is-python3 xvfb x11vnc xdotool wget tar supervisor net-tools fluxbox gnupg2 && \
  echo 'echo -n $HOSTNAME' > /root/x11vnc_password.sh && chmod +x /root/x11vnc_password.sh && \
  mkdir -pm755 /etc/apt/keyrings && \
  wget -qO - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key - && \
  wget -qNP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources && \
  apt-get update && apt-get -y install --install-recommends winehq-stable && \
  mkdir -p /opt/wine-stable/share/wine/mono && wget -qO - https://dl.winehq.org/wine/wine-mono/9.4.0/wine-mono-9.4.0-x86.tar.xz | tar -xJv -C /opt/wine-stable/share/wine/mono && \
  mkdir -p /opt/wine-stable/share/wine/gecko && wget -qO /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.4-x86.msi https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86.msi && \
  wget -qO /opt/wine-stable/share/wine/gecko/wine-gecko-2.47.4-x86_64.msi https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86_64.msi && \
  apt-get -y full-upgrade && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisord-wine.conf /etc/supervisor/conf.d/supervisord-wine.conf

ENV WINEPREFIX=/root/.wine64
ENV WINEARCH=win64
ENV DISPLAY=:0

WORKDIR /root/
RUN wget -qO tmp.zip https://www.python.org/ftp/python/3.9.13/python-3.9.13-embed-amd64.zip && \
  unzip tmp.zip -d /opt/python-3.9.13 && rm tmp.zip && \
  echo 'Lib\site-packages' >> /opt/python-3.9.13/python39._pth && \
  wget -qO /opt/python-3.9.13/get-pip.py https://bootstrap.pypa.io/get-pip.py && \
  wget -qO /usr/local/bin/winetricks http://www.kegel.com/wine/winetricks && \
  chmod a+x /usr/local/bin/winetricks && \
  wget -qO - https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | tar -xzv -C /root/ && mv /root/noVNC-1.3.0 /root/novnc && ln -s /root/novnc/vnc_lite.html /root/novnc/index.html && \
  wget -qO - https://github.com/novnc/websockify/archive/v0.11.0.tar.gz | tar -xzv -C /root/ && mv /root/websockify-0.11.0 /root/novnc/utils/websockify

COPY initial.sh /opt/initial.sh

EXPOSE 8080

CMD ["/usr/bin/supervisord"]

