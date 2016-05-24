#!/bin/bash
set -x
DIR="`dirname \"$0\"`"
FILES=`pwd`/stored_*query_definitions/*xml 
for FILE in $FILES; do
  /var/lib/openinfoman/bin/basex  -b file=$FILE   $DIR/update_cp_926.xq
done

