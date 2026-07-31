FROM ubuntu:22.04

# 全局环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DISPLAY=:1 \
    VNC_PWD=Edu@9527 \
    ROOT_PWD=Edu@9527

# 1. 时区 + 中文本地化
RUN apt update && apt install -y tzdata locales && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && locale-gen

# 2. 安装基础工具、SSH、Xfce桌面、VNC、中文字体、fcitx5拼音输入法
RUN apt install -y --no-install-recommends \
    # 基础运维软件
    openssh-server net-tools iproute2 curl wget git vim  \
    unzip zip tar  ca-certificates software-properties-common \
    # Xfce桌面全套
    xfce4 xfce4-goodies xorg dbus-x11 firefox-esr gnome-terminal thunar \
    # VNC服务
    tigervnc-standalone-server tigervnc-viewer \
    # 中文输入法fcitx5 + 拼音
    fcitx5 fcitx5-chinese-addons fcitx5-configtool fcitx5-gtk fcitx5-qt \
    # 中文字体
    fonts-wqy-zenhei fonts-wqy-microhei fonts-noto-cjk

# 清理缓存缩小镜像
RUN apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

# ========== SSH配置：允许root密码登录 ==========
RUN echo "root:$ROOT_PWD" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir -p /var/run/sshd

# ========== VNC root配置 ==========
RUN mkdir -p /root/.vnc && \
    echo "$VNC_PWD" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# 输入法环境变量写入全局配置（所有终端/桌面生效）
RUN echo 'export GTK_IM_MODULE=fcitx5' >> /etc/profile && \
    echo 'export QT_IM_MODULE=fcitx5' >> /etc/profile && \
    echo 'export XMODIFIERS=@im=fcitx5' >> /etc/profile && \
    echo 'export INPUT_METHOD=fcitx5' >> /etc/profile && \
    echo 'export SDL_IM_MODULE=fcitx5' >> /etc/profile

# 启动脚本：同时启动sshd + vnc桌面 + 输入法
RUN echo '#!/bin/bash' > /root/start_all.sh && \
    echo 'source /etc/profile' >> /root/start_all.sh && \
    # 启动ssh服务
    echo '/usr/sbin/sshd -D &' >> /root/start_all.sh && \
    # 杀死残留vnc
    echo 'vncserver -kill :1 >/dev/null 2>&1' >> /root/start_all.sh && \
    # 启动dbus会话
    echo 'dbus-daemon --session --fork' >> /root/start_all.sh && \
    # 启动fcitx5输入法后台
    echo 'fcitx5 -d &' >> /root/start_all.sh && \
    # 启动VNC，开放外网访问，端口5901
    echo 'vncserver :1 -geometry 1920x1080 -depth 24 -localhost no' >> /root/start_all.sh && \
    # 前台阻塞保持容器运行
    echo 'tail -f /dev/null' >> /root/start_all.sh && \
    chmod +x /root/start_all.sh

# 暴露端口
EXPOSE 22 5901

# 容器启动入口
CMD ["/root/start_all.sh"]
