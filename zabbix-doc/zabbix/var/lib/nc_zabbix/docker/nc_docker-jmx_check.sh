#/bin/bash
#######################################
#jmx monitor script
#######################i###############
#Create by ML   mason.liu@chinanetcloud.com
#
# version 1.0.0
#
# ChangeLog
#  2010-05-19    ML    initial creation
#  2010-05-21    VV    format / merge zabbix agent arguments to allow 
#                use of original zabbix template
#  2010-05-23    VV    Major redesign - reoarganisation + simplify merge fct
#                + user / pass
#  2012-02-13    CZ      add config file for override defaults

### Error Code ###
# -0.9901 --- the java does not exist or not executable
# -0.9902 --- the mbeans argument is empty
# -0.9903 --- the property argument is empty
# -0.9904 --- wrong JMX port - connection refused
# -0.9905 --- wrong login pass for jmx-remote access
# -0.9906 --- wrong parameters either mbeans or property
# -0.9907 --- no value

# Load PATH from profile
[ -f /etc/profile ] && . /etc/profile

###
# Binary definition
##
CURRENT_DIR=$(readlink -f $(dirname $0))
JAR="/cmdline-jmxclient-0.10.3.jar"
JAVA=$(which java) # rely on PATH - override in config file if required.

# JMX definition
JMX_HOST="127.0.0.1"
JMX_DEFAULT_PORT="6789"
JMX_USER="zabbix_check"
JMX_PASS="zabbix_check"

# Override defaults from config file
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_jmx_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF

#######
# JMX mBean name can have multiple comma / separator
#  need to concat all the parameters
#######

process_zabbix_arguments() {

    # init JMX string
    JMX_STRING=

    while true ; do
        # If no more data in arguments - exit loop
        if [ -z "$1" ]; then
            break
        fi
        
        # remerge the arguments
        [ -z "$JMX_STRING" ] && JMX_STRING="$1" || JMX_STRING="$JMX_STRING","$1"
        shift
    done

    # Process arguments
    # Structure :
    #  java.lang:type=GarbageCollector,name=PS MarkSweep][CollectionCount (][jmx_port)
    #                     mBean-name                    ][ property,sub   (][jmx_port)
    #
    #    mBean-name: string
    #    property: string - with subproperty
    #    jmx_port: integer - optional
    #
    
    BEAN_NAME=$(echo "$JMX_STRING" | awk 'BEGIN { FS="]\\[" }; {print $1}')
    PROPERTY=$(echo "$JMX_STRING" | awk 'BEGIN { FS="]\\[" }; {print $2}' | awk 'BEGIN { FS="," }; {print $1}')
    SUB_PROPERTY=$(echo "$JMX_STRING" | awk 'BEGIN { FS="]\\[" }; {print $2}' | awk 'BEGIN { FS="," }; {print $2}')
    JMX_PORT=$(echo "$JMX_STRING" | awk 'BEGIN { FS="]\\[" }; {print $3}')
    CONTAINER_NAME=$(echo "$JMX_STRING" | awk 'BEGIN { FS="]\\[" }; {print $4}')

}


#test the input is not empty,the jmx port default is 6789
#test the java is whether available
test_bin (){
    [ ! -f "$JAVA" ] && echo "-0.9901" && exit 1
    [ ! -x "$JAVA" ] && echo "-0.9901" && exit 1
}

test_argument()
{
    [ -z "$BEAN_NAME" ] && echo "-0.9902" && exit 1
    [ -z "$PROPERTY" ] && echo "-0.9903" && exit 1
    [ -z "$JMX_PORT" ] && JMX_PORT="$JMX_DEFAULT_PORT"
    [ "$JMX_PORT" == "default" ] && JMX_PORT="$JMX_DEFAULT_PORT"
}


###
# main part
###

test_bin
process_zabbix_arguments "$@"
test_argument

JMX_OUT=$(sudo docker exec -i "$CONTAINER_NAME" "$JAVA" -jar "$JAR" "$JMX_USER":"$JMX_PASS" "$JMX_HOST":"$JMX_PORT" "$BEAN_NAME" "$PROPERTY" 2>&1 | sed -ne '1 s/\([^\ ]* \)\{4\}//; 1p; 1!p')

# exclude errors - return error code instead
    JMX_ERROR_CONNECT=$(echo "$JMX_OUT" | grep -c 'refused')
    if [ "$JMX_ERROR_CONNECT" -ne 0 ]; then
    echo "-0.9904"
    exit 1
    fi

    JMX_ERROR_AUTH=$(echo "$JMX_OUT" | grep -c 'Authentication failed')
    if [ "$JMX_ERROR_AUTH" -ne 0 ]; then
    echo "-0.9905"
    exit 1
    fi    

    JMX_ERROR=$(echo "$JMX_OUT" | grep -Ec 'MalformedObjectNameException|not found.|not a registered bean|No such attribute')
    if [ "$JMX_ERROR" -ne 0 ]; then
        echo "-0.9906"
        exit 1
    fi

# We only want numbers...
#echo "$JMX_OUT" | /bin/awk '{ gsub( /[^0123456789]/, "" ); print $1 }'

# Or strings too ?
JMX_VALUE=
if [ ! -z "$SUB_PROPERTY" ]; then
    JMX_VALUE=$(echo "$JMX_OUT" | awk "/$SUB_PROPERTY/ { FS=\": \"; print \$2}")
else
    JMX_VALUE=$(echo "$JMX_OUT" | awk 'BEGIN { FS=": " }; {print $2}')
fi

if [ -z "$JMX_VALUE" ]; then
    echo "-0.9907" 
else
    echo "$JMX_VALUE"
fi

exit 0
