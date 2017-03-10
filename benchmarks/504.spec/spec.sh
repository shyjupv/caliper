#!/bin/bash

#spec binary package need has the key word: "spec.*cpu", ".tar.gz" or ".zip"
#after unpack the directory need has the key word: "spec.*cpu"
#for example: spec_CPU_2006_x86_64_2.tar.gz

typeTest=${1:-int}
typeCore=${2:-single}

drCur1=$(pwd)
nCopy=1

grep -iq "multi" <<< "${typeCore}"
if [ $? -eq 0 ]; then
    nCopy=$(grep "processor" /proc/cpuinfo |wc -l)
    #grep 'processor' /proc/cpuinfo |sort |uniq |wc -l
fi
printf "%s[%3d]%s[%3d]%5s: [number of processors:${nCopy}]\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${FUNCNAME[0]}" ${LINENO} "Info"

grep -q "^[0-9]\+\$" <<< "${nCopy}"
if [ $? -ne 0 ]; then
    printf "%s[%3d]%s[%3d]%5s: [${typeCore}] not correct !\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${FUNCNAME[0]}" ${LINENO} "Error"
    exit 1
fi

flList=$(find . -maxdepth 1 -type f |grep -i "spec.*cpu")
flTarz=$(grep "\.tar\.gz\$" <<< "${flList}")
flZip1=$(grep "\.zip\$" <<< "${flList}")

if [ -n "${flTarz}" -a -n "${flZip1}" ]; then
    printf "%s[%3d]%s[%3d]%5s: can not know which package:\n${flTarz}\n${flZip1}\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${FUNCNAME[0]}" ${LINENO} "Error"
    exit 1
fi

flagUnpack=false
if [ -n "${flTarz}" ]; then
    nRow1=$(wc -l <<< "${flTarz}")
    if [ "${nRow1}" -ne 1 ]; then
        printf "%s[%3d]%s[%3d]%5s: too many packages:\n${flTarz}\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${FUNCNAME[0]}" ${LINENO} "Error"
        exit 1
    else
        tar -xzf ${flTarz}
        flagUnpack=true
    fi
fi
if ! ${flagUnpack}; then
    if [ -n "${flZip1}" ]; then
        nRow1=$(wc -l <<< "${flZip1}")
        if [ "${nRow1}" -ne 1 ]; then
            printf "%s[%3d]%s[%3d]%5s: too many packages:\n${flZip1}\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${FUNCNAME[0]}" ${LINENO} "Error"
            exit 1
        else
            unzip ${flZip1}
            flagUnpack=true
        fi
    fi
fi

if ! ${flagUnpack}; then
    printf "%s[%3d]%s[%3d]%5s: can not found spec package in [${drCur1}]\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${FUNCNAME[0]}" ${LINENO} "Error"
    exit 1
fi

drSpec1=$(find . -maxdepth 1 -type d |grep -i "spec.*cpu")
if [ -z "${drSpec1}" ]; then
    printf "%s[%3d]%s[%3d]%5s: unknow the spec folder\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${FUNCNAME[0]}" ${LINENO} "Error"
    exit 1
fi
nRow1=$(wc -l <<< "${drSpec1}")
if [ "${nRow1}" -ne 1 ]; then
    printf "%s[%3d]%s[%3d]%5s: too many folders:\n${drSpec1}\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "${FUNCNAME[0]}" ${LINENO} "Error"
    exit 1
fi
cd ${drSpec1}*

#####################
flCfg1=cpu_670_6.1.cfg
flCfg1=lemon-2cpu.cfg
flSpecLog=~/tmp/spec.log

mkdir -p ~/tmp

. ./shrc
./bin/relocate
./bin/runspec -c "${flCfg1}" ${typeTest} --rate ${nCopy} -n 1 --noreportable > "${flSpecLog}"

sLog1=$(grep -B3 "runspec finished" "${flSpecLog}")
key1="The log for this run is in"
sLog2=$(grep "${key1}" <<< "${sLog1}")
flBSLog=$(sed "s#^[ \t]*${key1}[ \t]\+##;s#[ \t]*\$##" <<< "${sLog2}")
cat "${flBSLog}"

#####################

