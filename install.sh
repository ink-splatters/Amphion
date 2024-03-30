#!/usr/bin/env bash

set -e

ENV=${ENV:-amphion}

_last_tool=

function _check_tool() {

	local exists=0
	for x in "$@"; do
		if command -v "$x" >/dev/null 2>&1; then
			exists=1
			echo - $x installed
			_last_tool="$x"
			break
		fi
	done

	if [ $exists = 0 ]; then
		if [ $# -gt 1 ]; then
			echo
			printf "%s" "- none of the following tools installed: $1"
		else
			printf "%s" "- $1 NOT installed"
		fi

		shift

		for x in "$@"; do
			printf ", %s" "$x"
		done
		echo
		echo
		exit 1
	fi

}

function _install_deps() {

	pip install -U encodec

	echo "- installing python..."
	$conda install -c conda-forge python=3.9
	pip install -U pip wheel setuptools

	echo "- installing requirements..."
	pip install https://github.com/vBaiCai/python-pesq/archive/master.zip
	pip install git+https://github.com/lhotse-speech/lhotse
	pip install -U encodec
	pip install -r requirements.txt
	echo "- installation complete"

}

function _activate() {
	$conda activate $ENV
	echo "- $conda environment activated"
}

_check_tool ffmpeg

_check_tool conda micromamba
conda=${_last_tool}

echo
echo "- using $conda to manage python environment: $ENV"

if ! command $conda activate $ENV 2>/dev/null; then
	echo "- does not exist. creating..."
	$conda env create -n $ENV
	_activate

	_install_deps

else
	if [ "$1" = "--reinstall" ]; then
		echo "- --reinstall flag provided, re-installing..."
		$conda env remove -n $ENV
		$conda env create -n $ENV
		_activate
		_install_deps
	else
		_activate
	fi
fi
