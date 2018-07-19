#/bin/bash
# finduser

if [ $# -ne 1 ]
then
    echo Usage: finduser username >&2
    exit 1
fi

who | grep $1
