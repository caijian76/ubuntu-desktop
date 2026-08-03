#!/bin/sh
export LANG=zh_CN.UTF-8 
export LANGUAGE=zh_CN:zh
export LC_ALL=zh_CN.UTF-8
export DISPLAY=:1 
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

mkdir -p /root/.vnc
[ -f /root/.vnc/passwd ]||echo ${VNC_PASSWORD:-Edu@9527}|vncpasswd -f>/root/.vnc/passwd
chmod 600 /root/.vnc/passwd
cat >/root/.vnc/xstartup <<'EOF'
#!/bin/sh
eval "$(dbus-launch --sh-syntax)"
fcitx5 &
exec startxfce4
EOF
chmod +x /root/.vnc/xstartup
exec vncserver :1 -fg -localhost no -geometry ${VNC_GEOMETRY:-1920x1080} -depth ${VNC_DEPTH:-24}
