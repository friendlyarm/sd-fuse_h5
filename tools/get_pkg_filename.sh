#!/bin/bash

TARGET_OS=$(echo ${1,,}|sed 's/\///g')
case ${TARGET_OS} in
friendlycore-focal_4.14_arm64 | friendlycore-xenial_4.14_arm64 | friendlywrt_4.14_arm64 | eflasher)
	ROMFILE="${TARGET_OS}.tgz"
        ;;
*)
	ROMFILE=
esac
echo $ROMFILE
