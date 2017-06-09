#!/bin/bash
###############################
# Raid check wrapper
#
# This script has the decision logic to use either
# one of the raid check script provided for different
# RAID cards.
#
# This script DOES NOT HANDLE:
#  - multi raid cards
#  - unknown raid cards - it needs to be known via lspci
#  - unsupported raid cards - they need to be added to the script
#
###############################
# Contact:
#   vincent.viallet@gmail.com
###############################
# Changelog
#  20111207  VV  initial creation
#  20120717  MD  use absolute path
###############################

#
# List existing scripts
#
## Smart Array Card - usually HP servers
##    Hewlett-Packard Company Smart Array G6 controllers
SMARTARRAY="/var/lib/nc_zabbix/agent_bin/nc_raid-hpacucli_check.sh"
## Cheap RAID card SAS - usually entry level Dell servers
##    LSI Logic / Symbios Logic SAS1068E PCI-Express Fusion-MPT SAS
MPTSAS="/var/lib/nc_zabbix/agent_bin/nc_raid-mptstatus_check.sh"
## PERC RAID card - usually mid level (BBU capable) Dell servers 
##    LSI Logic / Symbios Logic MegaRAID SAS 1078
MEGARAID="/var/lib/nc_zabbix/agent_bin/nc_raid-megacli_check.sh"
## SAS RAID card - new generation Dell servers
##    (R700) LSI Logic / Symbios Logic LSI MegaSAS 9260
##    (R200) LSI Logic / Symbios Logic SAS2008 PCI-Express Fusion-MPT SAS-2
SAS="/var/lib/nc_zabbix/agent_bin/nc_raid-sas2ircu_check.sh"
## Adaptec AACRaid series
ARCCONF="/var/lib/nc_zabbix/agent_bin/nc_raid-arcconf_check.sh"

#
# RAID card discovery
#
#  Need to define which model of the card is in the box
#  using lspci or other tools
#
#  Other cards can be supported by extending the grep REGEX
#
LSPCI_OUTPUT=$(/sbin/lspci 2> /dev/null)

IS_SMARTARRAY=$(echo "$LSPCI_OUTPUT" | grep -cE 'Smart Array')
IS_MPTSAS=$(echo "$LSPCI_OUTPUT" | grep -cE 'SAS1068')
IS_MEGARAID=$(echo "$LSPCI_OUTPUT" | grep -cE 'MegaSAS|MegaRAID')
IS_SAS=$(echo "$LSPCI_OUTPUT" | grep -cE 'SAS2008')
IS_ARCCONF=$(echo "$LSPCI_OUTPUT" | grep -cE 'Adaptec')

# first one first served...
if [ $IS_SMARTARRAY -gt 0 ]; then
    bash $SMARTARRAY $1 $2
    exit $?
fi

if [ $IS_MPTSAS -gt 0 ]; then
    bash $MPTSAS $1 $2
    exit $?
fi

if [ $IS_MEGARAID -gt 0 ]; then
    bash $MEGARAID $1 $2
    exit $?
fi

if [ $IS_SAS -gt 0 ]; then
    bash $SAS $1 $2
    exit $?
fi

if [ $IS_ARCCONF -gt 0 ]; then
    bash $ARCCONF $1 $2
    exit $?
fi

# No known RAID card has been found
# Report error to Zabbix and require investigation
echo "Unknown RAID card, fix $(basename $0) script RAID card discovery"
exit 1

