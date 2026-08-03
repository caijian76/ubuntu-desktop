FROM docker.m.daocloud.io/library/ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai 
    
RUN apt-get update && apt upgrade -y && apt-get install -y \
    tini supervisor sudo openssh-server dbus-x11 \
    tzdata openssh-server net-tools iproute2 iputils-ping curl wget git vim \
    unzip zip tar ca-certificates software-properties-common \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server tigervnc-tools \
    locales language-pack-zh-hans fonts-noto-cjk fonts-wqy-zenhei fcitx5 fcitx5-chinese-addons fcitx5-config-qt fcitx5-frontend-gtk3 fcitx5-frontend-qt5 fcitx5-module-xorg \   
    && apt remove -y --purge xfce4-power* xfce4-screensaver* \
    && apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

# 时区 + 中文本地化
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && locale-gen 


# install firefox
RUN install -d -m 0755 /etc/apt/keyrings && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null \
    && echo "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n\nPackage: firefox*\nPin: release o=Ubuntu\nPin-Priority: -1" | tee /etc/apt/preferences.d/mozilla \
    && apt update && apt install -y firefox

# 初始化root密码，允许root登录ssh，允许密码登录ssh
RUN echo "root:Edu@9527" | chpasswd \
    && mkdir -p /var/run/sshd \
    && sed -ri 's/^#?PermitRootLogin.*/PermitRootLogin yes/;s/^#?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && ssh-keygen -A

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY start-vnc.sh /start-vnc.sh
COPY fcitx5 /root/.config/fcitx5
RUN chmod +x /entrypoint.sh /start-vnc.sh
EXPOSE 22 5901
ENTRYPOINT ["/entrypoint.sh"]
