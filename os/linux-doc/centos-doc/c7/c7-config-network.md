# nmcli c modify eth0 ipv4.addresses 10.0.0.30/24

nmcli c modify eth0 ipv4.gateway 10.0.0.1 

nmcli c modify eth0 ipv4.dns 10.0.0.1 

nmcli c modify eth0 ipv4.method manual 

nmcli c down eth0; nmcli c up eth0 

nmcli d show eth0 
