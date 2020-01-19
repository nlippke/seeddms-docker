#!/bin/bash

set -e

inputpdf=$1
tmpdir=/tmp/seed
lockfile=$tmpdir/`basename $0`
cores=2

mkdir -p $tmpdir

while [ -e "$lockfile" ];
do
    sleep 5
done

if ( set -o noclobber; echo "locked" > "$lockfile"); then
  trap 'rm -f "$lockfile"; exit $?'  INT TERM KILL EXIT
else
  exit 1
fi

pdf_contents=`pdftotext -nopgbrk $1 - | sed -e 's/ [a-zA-Z0-9.]\{1\} / /g' -e 's/[0-9.]//g'`
if [ -z "$pdf_contents" ]; then
  echo "ocrmypdf $1"
  tmpfile=$tmpdir/`date +%s%N`
  ocrmypdf -l deu --rotate-pages --jobs $cores --output-type pdfa $1 $tmpfile 2> /dev/null
  pdf_contents=`pdftotext -nopgbrk $tmpfile - | sed -e 's/ [a-zA-Z0-9.]\{1\} / /g' -e 's/[0-9.]//g'`
  mv $tmpfile $1
fi
echo $pdf_contents
