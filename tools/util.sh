#!/bin/bash
set -eu

function has_built_uboot() {
	if [ -f $1/sunxi-spl.bin ]; then
		echo 1
	else
		echo 0
	fi
}

function has_built_kernel() {
	local ARCH=arm64
	local KIMG=arch/${ARCH}/boot/Image
	if [ -f $1/${KIMG} ]; then
		echo 1
	else
		echo 0
	fi
}

function has_built_kernel_modules() {
	local OUTDIR=${2}
	local SOC=h5
	if [ -d ${OUTDIR}/output_${SOC}_kmodules ]; then
		echo 1
	else
		echo 0
	fi
}

