#!/bin/sh
mkdir -p /root/.vnc
[ -f /root/.vnc/passwd ]||echo ${VNC_PASSWORD:-123456}|vncpasswd -f>/root/.vnc/passwd
chmod 600 /root/.vnc/passwd
cat >/root/.vnc/xstartup <<'EOF'
#!/bin/sh
eval "$(dbus-launch --sh-syntax)"
fcitx5 &
exec startxfce4
EOF
chmod +x /root/.vnc/xstartup
exec vncserver :1 -fg -localhost no -geometry ${VNC_GEOMETRY:-1920x1080} -depth ${VNC_DEPTH:-24}
