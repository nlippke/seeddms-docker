#!/bin/bash

set -e

. /usr/local/bin/seeddms-settings.sh

lockfile=$tmpdir/`basename $0`
mkdir -p $tmpdir

if [ -e "$lockfile" ]; then
   log warn "indexing skipped because other indexer is already running"
   exit 1
fi

if ( set -o noclobber; echo "locked" > "$lockfile"); then
  trap 'rm -f "$lockfile"; exit $?'  INT TERM KILL EXIT
else
  exit 1
fi

pushd $SEEDDMS_HOME/utils > /dev/null

/usr/local/bin/php $SEEDDMS_HOME/utils/indexer.php --config $SEEDDMS_BASE/conf/settings.xml > /dev/null

popd > /dev/null
