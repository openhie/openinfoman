#!/bin/bash
set -x
DIR="`dirname \"$0\"`"
RFILES=`pwd`/stored_query_definitions/*xml 
UFILES=`pwd`/stored_updating_query_definitions/*xml 
FILES="$RFILES $UFILES"
for FILE in $FILES; do
  /var/lib/openinfoman/bin/basex  -b file=$FILE   $DIR/update_cp_926.xq
done

