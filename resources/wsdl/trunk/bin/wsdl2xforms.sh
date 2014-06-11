#!/bin/sh
# Usage: ./wsdl2xforms.sh wsdlpath xformspath "param1=value" "param2=value"
java -jar ../lib/saxon9.jar -s:$1 -o:$2 -xsl:../src/wsdl2xforms.xsl "writedocuments=true()" $3 $4 $5 $6 $7 $8 $9
