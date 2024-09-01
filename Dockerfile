FROM archlinux:base-20240825.0.257728 as builder
RUN pacman-key --init
RUN --mount=type=cache,target=/var/cache/ \
    pacman -Syyu --noconfirm base-devel git vim

RUN useradd -m docker_user && \
    passwd -d docker_user && \
    printf 'docker_user ALL=(ALL) ALL\n' | tee -a /etc/sudoers
USER docker_user
RUN --mount=type=cache,target=/var/cache/ \
    --mount=type=cache,target=/home/docker_user/.cache \
    cd /tmp && \
    git clone --depth=1 https://aur.archlinux.org/paru.git && \
    cd /tmp/paru && \
    makepkg -si --noconfirm && \
    true
RUN paru --noconfirm -S aur/janus-gateway
RUN paru -Qi janus-gateway
USER root
RUN sed -i -e 's|^#include "refcount.h"$|#include "../refcount.h"|g' /usr/include/janus/plugins/plugin.h
USER docker_user
RUN paru --noconfirm -S aur/ustreamer

#######################################################    
FROM archlinux:base-20240825.0.257728
ENV PIKVM_REPO_KEY=912C773ABBD1B584
RUN pacman -Sy --noconfirm archlinux-keyring vim systemd supervisor tesseract-data-chi_sim tesseract-data-eng

RUN mkdir -p /etc/gnupg && \
    echo standard-resolver >> /etc/gnupg/dirmngr.conf && \
    pacman-key --keyserver hkps://keyserver.ubuntu.com:443 -r $PIKVM_REPO_KEY \
        || pacman-key --keyserver hkps://keys.gnupg.net:443 -r $PIKVM_REPO_KEY \
        || pacman-key --keyserver hkps://pgp.mit.edu:443 -r $PIKVM_REPO_KEY
RUN pacman-key --init && \
    pacman-key --lsign-key $PIKVM_REPO_KEY

RUN echo -e "\n[pikvm]" >> /etc/pacman.conf && \
    echo "Server = https://files.pikvm.org/repos/arch/rpi4/" >> /etc/pacman.conf && \
    true
RUN --mount=type=cache,target=/var/cache/ \
    pacman -Sy --noconfirm  \
        --assume-installed raspberrypi-utils \
        kvmd kvmd-platform-v2-hdmi-rpi4 && \
    pacman -Rdd --noconfirm janus-gateway-pikvm ustreamer && \
    true

# Install deps from builder
RUN --mount=type=bind,from=builder,source=/,target=/builder \
    mkdir -p /tmp/prebuilt && \
    find /builder/home/docker_user/.cache/ -name "*.pkg.tar.*"  | xargs -I{} ln -s {} /tmp/prebuilt/ && \
    find /builder/var/cache/pacman/pkg/ -name "*.pkg.tar.*"  | xargs -I{} ln -s {} /tmp/prebuilt/ && \
    find /tmp/prebuilt -name "*.sig" | xargs -I{} unlink {} && \
    pacman --noconfirm -U /tmp/prebuilt/* && \
    rm -rfv /tmp/prebuilt && \
    true
    
# for Intel hardware encoding
RUN pacman -S --noconfirm intel-media-sdk 
ADD root/etc /etc
ADD root/lib /lib
ADD root/usr /usr
ADD root/pifs /pifs
ADD root/init /init
ADD root/supervisord.conf /supervisord.conf
RUN chmod +x /usr/local/bin/* && \
    chmod +x /usr/bin/vcgencmd && \
    chmod +x /usr/share/kvmd/*.sh && \
    chmod +x /init && \
    true

RUN echo mv --no-clobber /etc/janus/* /etc/kvmd/janus/ && \
    ls /usr/lib/janus/transports/* | grep -v websockets | xargs -I{} rm -fv {} && \
    cp -fv /usr/lib/janus/plugins/libjanus_streaming.* /usr/lib/ustreamer/janus/ && \
    sed -i 's/janus.plugin.ustreamer/janus.plugin.streaming/' /usr/share/kvmd/web/share/js/kvm/stream_janus.js && \
    sed -i 's/request\": \"watch\", \"p/request\": \"watch\", \"id\" : 1, \"p/' /usr/share/kvmd/web/share/js/kvm/stream_janus.js && \
    # sed -i '/__janus_enabled !== null/a __state.streamer={"instance_id":"","encoder":{"type":"CPU","quality":80},"sinks":{"jpeg":{"has_clients":false}},"source":{"resolution":{"width":1920,"height":1080},"online":true,"desired_fps":40,"captured_fps":18},"stream":{"queued_fps":0,"clients":0,"clients_stat":{}}}' /usr/share/kvmd/web/share/js/kvm/stream.js && \
    true
# Workaround for docker non privileged issues
RUN sed -i '/get_status(self,/a\        return (True, True)' /usr/lib/python3.12/site-packages/kvmd/apps/kvmd/sysunit.py && \
    sed -i '/open(self)/a\        return' /usr/lib/python3.12/site-packages/kvmd/apps/kvmd/sysunit.py  
RUN systemctl enable kvmd kvmd-nginx kvmd-janus-static kvmd-bootconfig kvmd-certbot kvmd-ipmi kvmd-vnc kvmd-ffmpeg
# Require privileged = true 
# RUN systemctl enable kvmd-watchdog 
STOPSIGNAL SIGRTMIN+3
ENTRYPOINT ["/init"]