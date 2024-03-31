#!/bin/zsh
set -e

ENV=${ENV:-amphion}
PYTHON_VER=${PYTHON_VER:-3.9}

_last_tool=

alias _pip='pip -v'

function _check_tool() {

	local exists=0
	for x in "$@"; do
		if command -v "$x" >/dev/null 2>&1; then
			exists=1
			echo "- $x installed"
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
function _install_python() {
	echo "- installing python..."
	$conda install -c conda-forge python=${PYTHON_VER}
	_pip install -U pip wheel setuptools
}
function _install_deps() {


	_pip install -U encodec

	echo "- installing requirements..."
	_pip install https://github.com/vBaiCai/python-pesq/archive/master.zip
	_pip install git+https://github.com/lhotse-speech/lhotse
	_pip install -U encodec
	_pip install -r requirements.txt
	echo "- installation complete"
}

function _activate() {
	local msg="- $conda environment $ENV"
	$conda activate $ENV && echo "$msg activated" || \
        { echo "$msg does not exist" ; return 1; }
}

_check_tool ffmpeg

_check_tool conda micromamba
conda=${_last_tool}

echo
echo "- using $conda to manage python environment: $ENV"
eval "$($conda shell hook --shell zsh)"

if [ "$1" = "--reinstall" ]; then
	echo "- --reinstall flag provided, re-installing..."
	$conda env remove -n $ENV
	$conda env create -n $ENV

	_activate
	_install_deps
else
    _activate && {
	args=( "$@" )
    } || {
	args=( --install-python --install-deps)

	echo "- creating..."
	$conda env create -n $ENV
	_activate
    }

    for arg in "${args[@]}"; do
	case "$arg" in
	    --install-python)
		_install_python
		;;
	    --install-deps)
		_install_deps
		;;

	    *)
		echo ERROR: unknown arg: $arg
		;;
	esac
    done

fi
