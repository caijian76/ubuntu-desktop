FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive LANG=zh_CN.UTF-8 LANGUAGE=zh_CN:zh LC_ALL=zh_CN.UTF-8 GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx XMODIFIERS=@im=fcitx
RUN apt-get update && apt-get install -y tini supervisor openssh-server dbus-x11 xfce4 xfce4-goodies xfce4-terminal tigervnc-standalone-server tigervnc-common locales language-pack-zh-hans fonts-noto-cjk fonts-wqy-zenhei fcitx5 fcitx5-chinese-addons fcitx5-config-qt fcitx5-frontend-gtk3 fcitx5-frontend-qt5 fcitx5-module-xorg && locale-gen zh_CN.UTF-8 && echo root:123456|chpasswd
RUN mkdir -p /var/run/sshd && sed -ri 's/^#?PermitRootLogin.*/PermitRootLogin yes/;s/^#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY start-vnc.sh /start-vnc.sh
COPY fcitx5 /root/.config/fcitx5
RUN chmod +x /entrypoint.sh /start-vnc.sh
EXPOSE 22 5901
ENTRYPOINT ["/entrypoint.sh"]