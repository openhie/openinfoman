#!/bin/sh
cd ../../bin
./schema2xforms.sh ../demos/purchaseOrder/purchaseOrder.xsd ../demos/purchaseOrder/purchaseOrder.xhtml "element=po:purchaseOrder" "formname=purchaseOrder"
cd ../demos/purchaseOrder
