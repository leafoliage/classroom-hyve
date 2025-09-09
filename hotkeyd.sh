#!/bin/sh

PYTHON_BIN=/usr/local/bin/python3.11
WORKDIR=/home/leaf/test_qt4
FILENAME=app_mac_do.py
pid=$(pgrep -f ${PYTHON_BIN} ${WORKDIR}/${FILENAME})

if [ -z ${pid} ]; then
	${PYTHON_BIN} ${WORKDIR}/${FILENAME} &
else
	pkill vncviewer 2&>1
	xdotool windowactivate $(xdotool search --onlyvisible --pid ${pid})
fi
