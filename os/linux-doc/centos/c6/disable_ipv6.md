# CentOS 6 禁用ipv6

- ipv6关闭
cat <<EOF>> /etc/modprobe.d/dist.conf
alias net-pf-10 off
alias ipv6 off
EOF

#