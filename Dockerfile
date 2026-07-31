FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=zh_CN.UTF-8 \
    LC_ALL=zh_CN.UTF-8 \
    DISPLAY=:1 \
    VNC_PWD=Edu@9527 \
    ROOT_PWD=Edu@9527

# 清空旧缓存，更新软件源
RUN rm -rf /var/lib/apt/lists/* && apt update

# 1. 基础工具、时区、语言组件
RUN apt install -y --no-install-recommends \
    tzdata locales openssh-server net-tools iproute2 curl wget git vim \
    unzip zip tar ca-certificates software-properties-common

# 时区 + 中文本地化
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && locale-gen

# 2. Xfce桌面 + Tigervnc（先装VNC，后面才能用vncpasswd）
RUN apt install -y --no-install-recommends \
    xfce4 xfce4-goodies xorg dbus-x11 gnome-terminal thunar \
    tigervnc-standalone-server

# 3. 浏览器 Firefox
RUN apt install -y --no-install-recommends firefox

# 4. Fcitx5 拼音输入法（匹配apt search真实包名）
RUN apt install -y --no-install-recommends \
    fcitx5 \
    fcitx5-modules \
    fcitx5-chinese-addons \
    fcitx5-pinyin \
    fcitx5-config-qt \
    fcitx5-frontend-gtk3 \
    fcitx5-module-cloudpinyin \
    fonts-wqy-zenhei fonts-wqy-microhei fonts-noto-cjk

# 清理缓存
RUN apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

# ========== SSH配置：允许root密码登录 ==========
RUN echo "root:$ROOT_PWD" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir -p /var/run/sshd

# ========== VNC root配置（现在tigervnc已安装，vncpasswd存在） ==========
RUN mkdir -p /root/.vnc && \
    echo "$VNC_PWD" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# 输入法全局环境变量
RUN echo 'export GTK_IM_MODULE=fcitx5' >> /etc/profile && \
    echo 'export QT_IM_MODULE=fcitx5' >> /etc/profile && \
    echo 'export XMODIFIERS=@im=fcitx5' >> /etc/profile && \
    echo 'export INPUT_METHOD=fcitx5' >> /etc/profile && \
    echo 'export SDL_IM_MODULE=fcitx5' >> /etc/profile

# 统一启动脚本：sshd + fcitx5 + vnc
ADD start_all.sh /root
RUN chmod +x /root/start_all.sh

EXPOSE 22 5901
CMD ["/root/start_all.sh"]
