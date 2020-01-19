#!/bin/bash

. /usr/local/bin/seeddms-settings.sh

lockfile=$tmpdir/`basename $0`
mkdir -p $tmpdir

if [ -e "$lockfile" ]; then
   log warn "indexing skipped because other backup is already running"
   exit 1
fi

if ( set -o noclobber; echo "locked" > "$lockfile"); then
  trap 'rm -f "$lockfile"; exit $?'  INT TERM KILL EXIT
else
  exit 1
fi

backupdir=$SEEDDMS_BASE/backup

mkdir -p $backupdir/data

rsync -avu --delete $SEEDDMS_BASE/data/1048576 $backupdir/data
if [ $? != 0 ]; then
	log error "Backup (rsync) failed"
fi

cp -auf $SEEDDMS_BASE/data/content.db $backupdir/data
if [ $? != 0 ]; then
	log error "Backup (database) failed"
fi

cp -auf $SEEDDMS_BASE/data/conf $backupdir/data
if [ $? != 0 ]; then
	log error "Backup (config) failed"
fi