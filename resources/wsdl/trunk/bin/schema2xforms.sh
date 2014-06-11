#!/bin/sh
# Usage: ./schema2xforms.sh schemapath xformspath "param1=value" "param2=value"
java -jar ../lib/saxon9.jar -s:$1 -o:$2 -xsl:../src/schema2xforms.xsl $3 $4 $5 $6 $7 $8 $9
