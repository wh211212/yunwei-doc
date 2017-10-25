# 安全审计

yum -y install lynis

## 查看审计报告

grep -E "^warning|^suggestion" /var/log/lynis-report.dat 


