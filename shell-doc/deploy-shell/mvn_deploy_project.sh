#!/bin/bash
##################################################################################################
#    Aniu api service deploy
#
#    Description:
#    - deploy all api 
#    - deploy all admin
#    - deploy product-api,product-service
##################################################################################################
#
#    CHANGELOG
#
#    History
#    2016-12-14      wanghui     First version release for testing
#    2016-12-30      wanghui     add remote exceute script
#    2017-02-14      wanghui     gather all project in one script
#    2017-02-20      wanghui     fix bug, then failed, function exit o change to exit 1
##################################################################################################

version_num=2016-12-12
#set -xe
##################################################################################################
#       set variable
##################################################################################################
Date_Format="date +%F_%T"
Old_Project=/data/gitlab/old-project
New_Project=/data/svn/aniu-project
Crm_Project=/data/svn/v2.0
Nkm_Project=/data/svn/nkm-admin
#

##################################################################################################
#   Old Project: mvn clean package -Dmaven.test.skip=true -q
##################################################################################################
#
jar() {
  echo "******  Begin deploy dependency jar. ******"
  #mvn_cmd=`mvn clean deploy -q`

  cd $Old_Project/tysx-mms-base && svn up && mvn clean deploy -q
  if [ $? -eq 0 ];
    then
      echo "################################################"
      echo "#-- Dependency tysx-mms-base deploy succeed! --#"
      echo "################################################"
      cd $Old_Project/tysx-mms-db && svn up && mvn clean deploy -q
      if [ $? -eq 0 ];
        then
        echo "##############################################"
        echo "#-- Dependency tysx-mms-db deploy succeed! --#"
        echo "##############################################"
        cd $Old_Project/tysx-mms-service && svn up && mvn clean deploy -q
        if [ $? -eq 0 ];
          then
            echo "###################################################"
            echo "#-- Dependency tysx-mms-service deploy succeed! --#"
            echo "###################################################"
          else
            echo "###################################################"
            echo "#-- Dependency tysx-mms-service deploy failed! --#"
            echo "###################################################"
            exit 1
        fi
        else
        echo "##############################################"
        echo "#-- Dependency tysx-mms-db deploy failed! --#"
        echo "##############################################"
        exit 1
      fi
    else
    echo "################################################"
    echo "#-- Dependency tysx-mms-base deploy failed! --#"
    echo "################################################"
    exit 1
  fi
}

#################################################################################################
# Old project: aniu api deploy 
#################################################################################################

api() {
  echo "******  Use jar for deploy aniu-api.  *******"
  #mvn_cmd=`mvn clean package -Dmaven.test.skip=true -q`
  jar
  if [ $? -eq 0 ];then
    cd $Old_Project/aniu-api && svn up && mvn clean package -Dmaven.test.skip=true -q
    if [ $? -eq 0 ];then
      echo "###################################"
      echo "### --  Api deploy succeed!  -- ###"
      else
      echo "###################################"
      echo "### --  Api deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##################################################"
  echo "### Can't use jar,beause deploy jar was failed! ###"
  exit 1
fi
}
#############################################################################################
# Old project: aniu api deploy 
#################################################################################################

admin() {
  echo "******  Use jar for deploy aniu-admin.  *******"
  jar
  if [ $? -eq 0 ];then
    cd $Old_Project/aniu-admin && svn up && mvn clean package -Dmaven.test.skip=true -q
    if [ $? -eq 0 ];then
      echo "#####################################"
      echo "### --  Admin deploy succeed!  -- ###"
      else
      echo "#####################################"
      echo "### --  Admin deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##################################################"
   echo "### Can't use jar,beause deploy jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# New project: aniu project deploy
# deploy aniu-dependency, aniu-module, aniu-core
#################################################################################################
#
kernel() {
  echo "******  Begin deploy dependency-module-core. ******"
  #mvn_cmd=`mvn clean deploy -q -Ponline`

  cd $New_Project/aniu-dependency && svn up && mvn clean deploy -q -Ponline
  if [ $? -eq 0 ];
    then
      echo "################################################"
      echo "#--      aniu-dependency deploy succeed!     --#"
      echo "################################################"
      cd $New_Project/aniu-module && svn up && mvn clean deploy -q -Ponline
      if [ $? -eq 0 ];
        then
        echo "##############################################"
        echo "#--   aniu-module deploy succeed!           --#"
        echo "##############################################"
        cd $New_Project/aniu-core && svn up && mvn clean deploy -q -Ponline
        if [ $? -eq 0 ];
          then
            echo "###################################################"
            echo "#--         aniu-core deploy succeed!           --#"
            echo "###################################################"
          else
            echo "###################################################"
            echo "#--         aniu-core deploy failed!            --#"
            echo "###################################################"
            exit 1
        fi
        else
        echo "##############################################"
        echo "#--         aniu-module deploy failed!     --#"
        echo "##############################################"
        exit 1
      fi
    else
    echo "################################################"
    echo "#--       aniu-dependency deploy failed!     --#"
    echo "################################################"
    exit 1
  fi
}

#################################################################################################
# New project: aniu project deploy
# deploy aniu-dependency, aniu-module, aniu-core
#################################################################################################
#
nkmcore() {
  echo "******  Begin deploy dependency-module-core. ******"
  #mvn_cmd=`mvn clean deploy -q -Ponline`

  cd $Nkm_Project/aniu-nkm-module && svn up && mvn clean deploy -q -Ponline
  if [ $? -eq 0 ];
    then
      echo "################################################"
      echo "#--      aniu-nkm-module deploy succeed!     --#"
      echo "################################################"
      cd $Nkm_Project/aniu-nkm-dao && svn up && mvn clean deploy -q -Ponline
      if [ $? -eq 0 ];
        then
        echo "##############################################"
        echo "#--   aniu-nkm-core deploy succeed!           --#"
        echo "##############################################"
        cd $Nkm_Project/aniu-nkm-redis && svn up && mvn clean deploy -q -Ponline
        if [ $? -eq 0 ];
          then
            echo "###################################################"
            echo "#--         aniu-nkm-redis deploy succeed!           --#"
            echo "###################################################"
            cd $Nkm_Project/aniu-nkm-factory && svn up && mvn clean deploy -q -Ponline
            if [ $? -eq 0 ];
              then
              echo "###################################################"
              echo "#--         aniu-nkm-factory deploy succeed!           --#"
              echo "###################################################"
            else
              echo "###################################################"
              echo "#--         aniu-nkm-factory deploy failed!            --#"
              echo "###################################################"
              exit 1
            fi
          else
            echo "###################################################"
            echo "#--         aniu-nkm-redis deploy failed!            --#"
            echo "###################################################"
            exit 1
          fi
        else
        echo "##############################################"
        echo "#--         aniu-nkm-core deploy failed!     --#"
        echo "##############################################"
        exit 1
      fi
    else
    echo "################################################"
    echo "#--       aniu-nkm-module deploy failed!     --#"
    echo "################################################"
    exit 1
  fi
}


#################################################################################################
# New project: deploy niukeme api, 80,81
#################################################################################################

niukeme() {
  echo "******  Use kernel jar for deploy niukeme api  *******"
  kernel
  nkmcore
#
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-api-product_nkm && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-api-product_nkm deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-api-product_nkm deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##########################################################"
   echo "### Can't use kernel jar,beause kernel jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# New project: deploy niukeme api task, 78-8083
#################################################################################################

niukeme_task() {
  echo "******  Use kernel jar for deploy niukeme api task *******"
  kernel
  nkmcore
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-api-product_nkm_task && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-api-product_nkm_task deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-api-product_nkm_task deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##########################################################"
   echo "### Can't use kernel jar,beause kernel jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# New project: aniu crm project dependency
#################################################################################################
#
crmcore(){
  echo "******  begin deploy crm dependency"
  cd $Crm_Project/aniu-crm-dependency && svn up && mvn clean deploy -Ponline -q
  if [ $? -eq 0 ];then 
      echo "###  aniu-crm-dependency deploy succeed! ###"
    else 
      echo "###  aniu-crm-dependency deploy failed! ###"
      exit 1
  fi
#
  cd $Crm_Project/aniu-crm-module && svn up && mvn clean deploy -Ponline -q
  if [ $? -eq 0 ];then 
      echo "###  aniu-crm-dependency deploy succeed! ###"
    else 
      echo "###  aniu-crm-dependency deploy failed! ###"
      exit 1
  fi
#
  cd $Crm_Project/aniu-crm-dao && svn up && mvn clean deploy -Ponline -q
  if [ $? -eq 0 ];then 
      echo "###  aniu-crm-dependency deploy succeed! ###"
    else 
      echo "###  aniu-crm-dependency deploy failed! ###"
      exit 1
  fi
#
  cd $Crm_Project/aniu-crm-service && svn up && mvn clean deploy -Ponline -q
  if [ $? -eq 0 ];then 
      echo "###  aniu-crm-dependency deploy succeed! ###"
    else 
      echo "###  aniu-crm-dependency deploy failed! ###"
      exit 1
  fi
#
  cd $Crm_Project/aniu-crm-core && svn up && mvn clean deploy -Ponline -q 
  if [ $? -eq 0 ];then 
      echo "###  aniu-crm-dependency deploy succeed! ###"
    else 
      echo "###  aniu-crm-dependency deploy failed! ###"
      exit 1
  fi
}

#################################################################################################
# New project: deploy aniu crm admin,8-8100
#################################################################################################

crm_admin() {
  echo "******  Use crm dependency for deploy aniu crm admin *******"
  crmcore
  if [ $? -eq 0 ];then
    cd $Crm_Project/aniu-crm-admin && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-crm-admin deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-crm-admin deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##############################################################"
   echo "### Can't use crm dependency,beause kernel jar was failed! ###"
  exit 1
fi
}



#################################################################################################
# New project: deploy aniu crm api, 65-8083, 73-8081
#################################################################################################

crm_api() {
  echo "******  Use crm dependency for deploy aniu crm admin *******"
  crmcore
  if [ $? -eq 0 ];then
    cd $Crm_Project/aniu-crm-api && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-crm-api deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-crm-api deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##############################################################"
   echo "### Can't use crm dependency,beause kernel jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# New project: deploy aniu-message-channel api, 38-8082, 40-8082
#################################################################################################

message() {
  echo "******  Use kernel jar for deploy message api  *******"
  kernel
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-message-channel && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-message-channel deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-message-channel deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##########################################################"
   echo "### Can't use kernel jar,beause kernel jar was failed! ###"
  exit 1
fi
}


#################################################################################################
# New project: deploy stock api, 80,81
#################################################################################################

stock() {
  echo "******  Use kernel jar for deploy stock api  *******"
  kernel
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-api-stock && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-api-stock deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-api-stock deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##########################################################"
   echo "### Can't use kernel jar,beause kernel jar was failed! ###"
  exit 1
fi
}
#
stockapi() {
  echo "******  Use kernel jar for deploy stock api  *******"
  kernel
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-api-stock && svn up && mvn clean deploy -q -Ptest
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-api-stock deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-api-stock deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##########################################################"
   echo "### Can't use kernel jar,beause kernel jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# New project: deploy vcms api, 78-8081,8082, 65-8082
#################################################################################################

vcms() {
  echo "******  Use kernel jar for deploy niukeme api  *******"
  kernel
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-vcms-api && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-vcms-api deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-vcms-api deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##########################################################"
   echo "### Can't use kernel jar,beause kernel jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# New project: deploy aniu-vcms-synch,  65-8081
#################################################################################################

vcms_synch() {
  echo "******  Use kernel jar for deploy aniu-vcms-synch  *******"
  kernel
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-vcms-synch && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-vcms-synch deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-vcms-synch deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##########################################################"
   echo "### Can't use kernel jar,beause kernel jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# New project: deploy aniu product dependency, 15,34 
#################################################################################################
#
product(){
  echo "******  begin deploy aniu product dependency  ******"
  cd $New_Project/aniu-dependency && svn up && mvn clean deploy -Ponline -q
  if [ $? -eq 0 ];then 
      echo "###  aniu-dependency deploy succeed! ###"
    else 
      echo "###  aniu-dependency deploy failed! ###"
      exit 1
  fi
#
  cd $New_Project/aniu-module && svn up && mvn clean deploy -Ponline -q
  if [ $? -eq 0 ];then 
      echo "###  aniu-module deploy succeed! ###"
    else 
      echo "###  aniu-module deploy failed! ###"
      exit 1
  fi
#
  cd $New_Project/aniu-product-dao && svn up && mvn clean deploy -Ponline -q
  if [ $? -eq 0 ];then 
      echo "###  aniu-product-dao deploy succeed! ###"
    else 
      echo "###  aniu-product-dao deploy failed! ###"
      exit 1
  fi
#
  cd $New_Project/aniu-product-service && svn up && mvn clean deploy -Ponline -q
  if [ $? -eq 0 ];then 
      echo "###  aniu-product-service deploy succeed! ###"
    else 
      echo "###  aniu-product-service deploy failed! ###"
      exit 1
  fi
#
  cd $New_Project/aniu-product-core && svn up && mvn clean deploy -Ponline -q 
  if [ $? -eq 0 ];then 
      echo "###  aniu-product-core deploy succeed! ###"
    else 
      echo "###  aniu-product-core deploy failed! ###"
      exit 1
  fi
}

#################################################################################################
# New project: deploy aniu-vcms-admin,  8-8092
#################################################################################################

vcms-admin() {
  echo "******  Use kernel jar for deploy vcms admin  *******"
  kernel
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-vcms-admin && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-vcms-admin deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-vcms-admin deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##########################################################"
   echo "### Can't use kernel jar,beause kernel jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# New project: deploy aniu-api-product,  15,34
#################################################################################################

product_api() {
  echo "******  Use product dependency for deploy aniu-service-product  *******"
  product
  aniu_pay
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-api-product && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-api-product deploy succeed!  -- ########"
      else
      echo "#####################################################"
      echo "### --  aniu-api-product deploy failed!  -- #########"
      exit 1
    fi
  else
   echo "#########################################################################"
   echo "### Can't use kernel jar,beause deploy product dependency was failed! ###"
  exit 1
fi
}


#################################################################################################
# New project: deploy aniu-service-product,  8-8091
#################################################################################################

product_service() {
  echo "******  Use product dependency for deploy aniu-service-product  *******"
  product
  if [ $? -eq 0 ];then
    cd $New_Project/aniu-service-product && svn up && mvn clean deploy -q -Ponline
    if [ $? -eq 0 ];then
      echo "#####################################################"
      echo "### --  aniu-service-product deploy succeed!  -- ###"
      else
      echo "#####################################################"
      echo "### --  aniu-service-product deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##########################################################"
   echo "### Can't use kernel jar,beause kernel jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# Old project: aniu mmadmin deploy 
#################################################################################################

mmadmin() {
  echo "******  Use jar for deploy aniu-mmsadmin.  *******"
  jar
  if [ $? -eq 0 ];then
    cd $Old_Project/tysx-mms-admin && svn up && mvn clean package -Dmaven.test.skip=true -q
    if [ $? -eq 0 ];then
      echo "#############################################"
      echo "### --  aniu-mmsadmin deploy succeed!  -- ###"
      else
      echo "#############################################"
      echo "### --  aniu-mmsadmin deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##################################################"
   echo "### Can't use jar,beause deploy jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# Old project: aniu-admin-icntv deploy 
#################################################################################################

admin_icntv() {
  echo "******  Use jar for deploy aniu-admin-icntv.  *******"
  jar
  if [ $? -eq 0 ];then
    cd $Old_Project/aniu-admin-icntv && svn up && mvn clean package -Dmaven.test.skip=true -q
    if [ $? -eq 0 ];then
      echo "#############################################"
      echo "### --  aniu-admin-icntv deploy succeed!  -- ###"
      else
      echo "#############################################"
      echo "### --  aniu-admin-icntv deploy failed!  -- ###"
      exit 1
    fi
  else
   echo "##################################################"
   echo "### Can't use jar,beause deploy jar was failed! ###"
  exit 1
fi
}

#################################################################################################
# New project: aniu-admin-icntv deploy 
#################################################################################################

aniu_pay() {
    echo "***  deploy aniou pay jar for product api  ***" 
    cd $Old_Project/aniu-pay && svn up && mvn clean deploy -q
    if [ $? -eq 0 ];then
      echo "#############################################"
      echo "### --  aniu-pay deploy succeed!  -- ###"
      else
      echo "#############################################"
      echo "### --  aniu-pay deploy failed!  -- ###"
      exit 1
    fi
}

#################################################################################################
# New project: aniu nkm admin project
#################################################################################################
nkm_admin() {
  #
  kernel
  nkmcore
  cd $Nkm_Project/aniu-nkm-admin
  # mvn nkm-admin
  svn up && mvn clean deploy -Ponline -q
  if [ $? -eq 0 ];then
    echo "mvn deploy nkm-admin sueeccd!"
  else
    echo "mvn deploy nkm-admin failed!"
    exit 1
  fi
}


#################################################################################################
# Script common functions
#################################################################################################

help() {
  printf "Usage: %s: [-i] [-I] [-k] [-K] [-T] [-c] [-C] [-m] [-M] [-s] [-v] [-V] [-Y] [-p] [-P] [-A] [-N] [-G] args" $(basename $0)
  printf "\n
  -h -- display help (this page)
  -i -- deploy aniu-api
  -I -- deploy aniu-admin
  -k -- deploy niukeme api
  -T -- deploy niukeme api task 
  -K -- deploy niukeme admin
  -C -- deploy aniu crm admin
  -c -- deplou aniu crm api 
  -m -- deploy aniu message api
  -s -- deploy aniu stock api
  -v -- deploy aniu vcms api
  -Y -- deploy aniu vcms admin 
  -V -- deploy aniu vcms synch
  -p -- deploy aniu product api
  -P -- deploy aniu product service
  -M -- deploy aniu mmsadmin
  -N -- deploy aniu admin icntv
  -G -- deploy aniu algoquote admin \n\n"
}

# display version number
#print_version() {
#  printf "Version: %s\n" $version_num
#}
# get options to play with and define the script behavior
get_options() {
  while getopts 'hiIkKTcCmMsSvVYpPANG' OPTION;
  do
    case "$OPTION" in
      h)    help
                exit 0
                ;;
      i)    api
                ;;
      I)    admin
                ;;
      k)    niukeme
                ;;
      T)    niukeme_task
                ;;
      K)    nkm_admin
                ;;
      C)    crm_admin
                ;;
      c)    crm_api
                ;;
      m)    message
                ;;
      s)    stock
                ;;
      S)    stockapi
                ;;
      v)    vcms
                ;;
      V)    vcms_synch
                ;;
      Y)    vcms-admin
                ;;
      p)    product_api
                ;;
      P)    product_service
                ;;
      M)    mmadmin
                ;;
      N)    admin_icntv
                ;;
      G)    algoquote_admin
                ;;
      ?)    help >&2
              exit 2
               ;;
    esac
    # if a parameter entered by the user is '-'
    if [ -z "$OPTION" ]; then
    echo -e "$RED ERROR: Invalid option entered $NO_COLOR" >&2
      help >&2
      exit 2
    fi
  done
}

# check that at least one parameter has been added when lauching the script
if [ -z "$@" ]; then
  help >&2
  exit 2
fi

parameter=`echo "$@" | awk '{print substr($0,0,1)}'`
if [ "$parameter" != "-" ]; then
  help >&2
  exit 2
fi

# get options
get_options "$@"
