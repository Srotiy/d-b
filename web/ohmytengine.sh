#!/bin/sh
Ver=2.3.2
apt update
apt install curl wget lsb-release -y
curl -O http://tengine.taobao.org/download/tengine-2.3.2.tar.gz
tar -xvf tengine-${Ver}.tar.gz
cd tengine-${Ver}
apt install libssl-dev libpcre3-dev zlib1g-dev libgeoip-dev libgd-dev -y
./configure --build=$(lsb_release -si) --user=www-data --group=www-data --prefix=/usr/local/tengine --conf-path=/etc/nginx/nginx.conf --sbin-path=/usr/sbin/ohmytengine --with-http_realip_module --with-http_ssl_module --with-http_v2_module --with-http_image_filter_module --with-http_geoip_module --with-http_sub_module --with-http_stub_status_module --with-http_random_index_module
make && make install

echo "# Stop dance for Tengine
# =======================
#
# ExecStop sends SIGSTOP (graceful stop) to the Tengine process.
# If, after 5s (--retry QUIT/5) Tengine is still running, systemd takes control
# and sends SIGTERM (fast shutdown) to the main process.
# After another 5s (TimeoutStopSec=5), and if Tengine is alive, systemd sends
# SIGKILL to all the remaining processes in the process group (KillMode=mixed).
#
# Tengine signals reference doc:
# http://Tengine.org/en/docs/control.html
#
[Unit]
Description=A high performance web server and a reverse proxy server
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/usr/local/tengine/logs/nginx.pid
ExecStartPre=/usr/sbin/ohmytengine -t -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/ohmytengine -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/ohmytengine -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /usr/local/tengine/nginx.pid
TimeoutStopSec=4
KillMode=mixed

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/tengine.service
systemctl daemon-reload
systemctl enable tengine
systemctl start tengine
echo -e "\033[32m"Done!"\033[0m"
echo -e "\033[32m"TengineDir: /usr/local/tengine/"\033[0m"
echo -e "\033[32m"BinaryFile: /usr/sbin/ohmytengine"\033[0m"
echo -e "\033[32m"NginxConfDir: /etc/nginx/"\033[0m"
echo -e "\033[32m"SystemdFile: /lib/systemd/system/tengine.service"\033[0m"
