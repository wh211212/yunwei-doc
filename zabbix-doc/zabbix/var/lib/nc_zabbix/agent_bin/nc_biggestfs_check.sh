#!/bin/bash
##################################
# Zabbix monitoring script
#
# biggestfs:
#  - monitor biggest mount point
#
##################################
# Contact:
#  daniel.lin@chinanetcloud.com
##################################
# ChangeLog:
#  20090731    DL      initial creation
#  20091013    VV    simplify script
#  20110212    DL    restructure the script, add binary check and data check
##################################
VERSION=1.0

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_DATA="-0.9903" # cannot get the system mount layout

# grab the highest used partion line from df
#       df -P           -- posix compliant - 1 line per system
#       /dev            -- we only want real block device -- add check on the type of the mount ?
#       sort -k 5 -n    -- sort numeric on the %use - 5th column
#       head            -- get only the biggest
#       awk             -- reformat output xx% /mount/point
BIGGESTFS=$( df -P | grep "^/dev" | sort -k 5 -n -r | head -1 | awk '{print $(NF-1)" "$NF}' )

# error during retrieve
if [ $? -ne 0 -o -z "$BIGGESTFS" ]; then
  echo $ERROR_DATA
  exit 1
fi

echo "$BIGGESTFS"
exit 0
