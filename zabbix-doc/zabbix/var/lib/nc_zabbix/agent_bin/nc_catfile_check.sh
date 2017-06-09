#!/bin/bash
#######################################
# Script to cat file for zabbix_agent #
#######################################
#                                     #
# 2010-06-04   CH   Init create          #
#                                      #
#================================================================================
#                                       
# Parameter meaning                                   
# $1: The file you want to cat or grep, use the name with full path.       
# $2: The keyword you want to grep in the file                   
# $3: The start line number of a block in the file you want to print
# $4: The end line number of a block in the file you want to print
# $5: The lines after keyword you want to print
# $6: The lines before keyword you want to print
# $7: Invert match the keyword or not, if you want to do that, put "1" here
# $8: Remove the comment lines or not, if you want to do that, put a number here.
#     - "1" means remove the comment begin with '#', like normal configuration file.
#     -    "2" means remove the comment begin with ';', like php.ini.
#     - "3" means remove the comment begin with '"', like vimrc.
# Support format:
#     - "$FILE_NAME" "_" "_" "_" "_" "_" "_" "_"
#     - "$FILE_NAME" "$KEYWORD" "_" "_" "_/num" "_/num" "_/0/1" "_/0/1/2/3"
#     - "$FILE_NAME" "$KEYWORD" "_" "_" "_/num" "_/num" "_/0/1" "_/0/1/2/3"
#     - "$FILE_NAME" "_" "$START_LINE" "$END_LINE" "_" "_" "_" "_/0/1/2/3"
#     - "$FILE_NAME" "_" "$START_LINE" "_" "_" "_" "_" "_/0/1/2/3"
#     - "$FILE_NAME" "_" "_" "$END_LINE" "_" "_" "_" "_/0/1/2/3"
#
#=================================================================================
#===================
# Parameter Define |
#===================
FILE_NAME=$1
KEYWORD=$2
START_LINE=$3
END_LINE=$4
AFTER_LINE=$5
BEFORE_LINE=$6
INVERT_MATCH=$7
REMOVE_COMMENT=$8
EMPTY_PARAM="_"
MAX_FILE_SIZE=$((1024*1024))

# Override defaults from config file
CURRENT_DIR=$(readlink -f $(dirname $0))
SCRIPT_CONF="$CURRENT_DIR/../conf/nc_catfile_check.conf"
[ -e "$SCRIPT_CONF" ] && source $SCRIPT_CONF
#############################################################
## Check whether the file exist and the permission for it. ##
#############################################################
check_file_exist_permission(){

    if [ ! -r $1 ]; then
        echo "File can't be read or doesn't exist!"
        exit 1    
    fi    
}

########################################################################
## Check the file size, we won't cat a file bigger than MAX_FILE_SIZE ##
########################################################################
check_file_size(){

    file_size=$(stat -c '%s' $1)
        if [ $file_size -eq 0 ]; then
        echo "Empty File"
                exit 1
        elif [ $file_size -gt $MAX_FILE_SIZE ]; then
        echo "Too Big File"
        exit 1
        fi

}

###########################
## Cat the file you want ##
###########################
cat_function(){

    cat "$FILE_NAME"

}

##################################
## Grep the keyword in the file ##
##################################
grep_function(){

    if [ "$INVERT_MATCH" == "$EMPTY_PARAM" -o "$INVERT_MATCH" == "0" ]; then
        grep_keyword=$(grep "$KEYWORD" "$FILE_NAME")
        if [ -z "$grep_keyword" ]; then
            echo "No Match" 
            exit 1
        else
            if [ "$REMOVE_COMMENT" == "$EMPTY_PARAM" -o "$INVERT_MATCH" == "0" ]; then
                grep -A ${AFTER_LINE/"_"/0} -B ${BEFORE_LINE/"_"/0} "$KEYWORD" "$FILE_NAME" | grep -v '^$'
            elif [ "$REMOVE_COMMENT" == "1" ]; then
                grep -A ${AFTER_LINE/"_"/0} -B ${BEFORE_LINE/"_"/0} "$KEYWORD" "$FILE_NAME" | grep -v '^#' | grep -v '^$'
            elif [ "$REMOVE_COMMENT" == "2" ]; then
                grep -A ${AFTER_LINE/"_"/0} -B ${BEFORE_LINE/"_"/0} "$KEYWORD" "$FILE_NAME" | grep -v '^;' | grep -v '^$'
            elif [ "$REMOVE_COMMENT" == "3" ]; then
                grep -A ${AFTER_LINE/"_"/0} -B ${BEFORE_LINE/"_"/0} "$KEYWORD" "$FILE_NAME" | grep -v '^"' | grep -v '^$'
            else
                echo "REMOVE_COMMENT must be "_" or number "0,1,2,3", please check!"
            fi
        fi
    elif [ "$INVERT_MATCH" == "1" ]; then
        if [ "$REMOVE_COMMENT" == "$EMPTY_PARAM" ]; then
            grep -v "$KEYWORD" "$FILE_NAME" | grep -v '^$'
        elif [ "$REMOVE_COMMENT" == "1" ]; then
            grep -v "$KEYWORD" "$FILE_NAME" | grep -v '^#' | grep -v '^$'
        fi
    else
        echo "INVERT_MATCH must be "_" or number "0,1", please check!"
        exit 1
    fi

}

################################################################
## Print a block in the file with the line number you support ##
################################################################
print_block_function(){

    if [ "$REMOVE_COMMENT" == "$EMPTY_PARAM" -o "$REMOVE_COMMENT" == "0" ]; then
        flag=$(sed -n "${START_LINE/"_"/1},${END_LINE/"_"/1}p" $FILE_NAME | grep -v '^$')
        if [ -z "$flag" ]; then
            echo "No Match"
        else
            sed -n "${START_LINE/"_"/1},${END_LINE/"_"/1}p" $FILE_NAME | grep -v '^$'
        fi
    elif [ "$REMOVE_COMMENT" == "1" ]; then
        flag=$(sed -n "${START_LINE/"_"/1},${END_LINE/"_"/1}p" $FILE_NAME | grep -v '^#' | grep -v '^$')
        if [ -z "$flag" ]; then
            echo "No Match"
        else
                    sed -n "${START_LINE/"_"/1},${END_LINE/"_"/1}p" $FILE_NAME | grep -v '^#' | grep -v '^$'
        fi
    elif [ "$REMOVE_COMMENT" == "2" ]; then
        flag=$(sed -n "${START_LINE/"_"/1},${END_LINE/"_"/1}p" $FILE_NAME | grep -v '^;' | grep -v '^$')
        if [ -z "$flag" ]; then
            echo "No Match"
        else
                    sed -n "${START_LINE/"_"/1},${END_LINE/"_"/1}p" $FILE_NAME | grep -v '^;' | grep -v '^$'
        fi
    elif [ "$REMOVE_COMMENT" == "3" ]; then
        flag=$(sed -n "${START_LINE/"_"/1},${END_LINE/"_"/1}p" $FILE_NAME | grep -v '^"' | grep -v '^$')
        if [ -z "$flag" ]; then
            echo "No Match"
        else
                    sed -n "${START_LINE/"_"/1},${END_LINE/"_"/1}p" $FILE_NAME | grep -v '^"' | grep -v '^$'
        fi
    else
        echo "NOT SUPPORT, PLEASE CHECK THE FORMAT AT THE BEGINNING OF SCRIPT!"
                exit 1
    fi

}

##############################################################################################
## The major function in this script, it will call other sub-function base on the parameter ##
##############################################################################################
catgrep_file(){

    check_file_exist_permission "$FILE_NAME"
        check_file_size $FILE_NAME

    if [ "$KEYWORD" == "$EMPTY_PARAM" -a "$START_LINE" == "$EMPTY_PARAM" -a "$END_LINE" == "$EMPTY_PARAM" -a "$AFTER_LINE" == "$EMPTY_PARAM" -a "$BEFORE_LINE" == "$EMPTY_PARAM" -a "$INVERT_MATCH" == "$EMPTY_PARAM" -a "$REMOVE_COMMENT" == "$EMPTY_PARAM" ]; then
        cat_function
    elif [ -n "$KEYWORD" -a "$START_LINE" == "$EMPTY_PARAM" -a "$END_LINE" == "$EMPTY_PARAM" ]; then
        grep_function
    elif [ "$KEYWORD" == "$EMPTY_PARAM" ] && [ "$INVERT_MATCH" == "$EMPTY_PARAM" ] && [ "$START_LINE" != "$EMPTY_PARAM" -o "$END_LINE" != "$EMPTY_PARAM" ] && [[ $REMOVE_COMMENT =~ [0123] ]] || [ "$REMOVE_COMMENT" == "$EMPTY_PARAM" ]; then
        print_block_function
        else
        echo "NOT SUPPORT, PLEASE CHECK THE FORMAT AT THE BEGINNING OF SCRIPT!"
        exit 1
    fi
}





case $1 in

    ""  )  echo -0.9903;;
    *   )  catgrep_file 

esac

exit 0

