#!/bin/bash

tmpdir=/tmp/seed
logfile=$SEEDDMS_BASE/data/log/`date +%Y%m%d`.log

function log() {
   printf "%s  [%s] -- (localhost) %s\n" "`date +"%b %d %H:%M:%S"`" $1 "$2" >> $logfile
}

export PATH=$PATH:/usr/local/bin
