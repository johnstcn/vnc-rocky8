FROM rockylinux:8

RUN dnf install -y epel-release && dnf --enablerepo=epel group

RUN dnf update -y && dnf install -y \
  bash \
  bind-utils \
  chromium \
  curl \
  firefox \
  git \
  novnc \
  openssh-clients \
  python3 \
  python3-pip \
  python3-websockify \
  sudo \
  supervisor \
  tigervnc-server \
  wget && \
  dnf -y -x gnome-keyring --skip-broken group install "Xfce" && \
  dnf erase -y *power* *screensaver* && \
  rm /etc/xdg/autostart/xfce-polkit* && \
  /bin/dbus-uuidgen > /etc/machine-id && \
  dnf clean all -y

# Fix for Chromium browser to not use CGroup sandboxing
RUN sed -i 's/--auto-ssl-client-auth "/--auto-ssl-client-auth --no-sandbox "/' /usr/lib64/chromium-browser/chromium-browser.sh

RUN useradd coder \
    --create-home \
    --shell=/bin/bash \
    --uid=1000 \
    --user-group
RUN usermod -aG wheel coder

COPY files/etc/supervisord.conf /etc/supervisord.conf
COPY files/etc/supervisord.d/* /etc/supervisord.d/
COPY files/opt/vnc /opt/vnc
COPY files/usr/share/novnc/index.html /usr/share/novnc/index.html
RUN chmod +x /opt/vnc/xstartup
RUN chown -R coder:coder /var/log/supervisor

USER coder

 # noVNC
EXPOSE 6060