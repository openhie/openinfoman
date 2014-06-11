XForms generators
=================

Schema2XForms - Creates XForms form for XML Schema.

WSDL2XForms - Creates XForms forms for SOAP-based web services. Services are 
described by their WSDL.

Xtee2XForms - Creates XForms forms for Estonian X-tee web services. Included 
as an example of extension mechanism.

Complex2XForms - Creates XForms forms for Estonian X-tee complex web services. 
Included as an example of extension mechanism.

Features
========

 * All (useful) XML Schema elements are supported, eg imports/includes work.
 * Implemented as XSL transformation.
 * Designed with extensibility in mind.

Usage
=====

Schema2XForms
-------------

schema2xforms.bat schemapath xformspath "param1=value" "param2=value"

Arguments:
 * schemapath - path to XML Schema file.
 * xformspath - path to XForms file.

Parameters:
 * debug - if true, then prints out tons of debugging information.
   By default false.
 * element - name of the element to generate form for, with namespace prefix.
   By default the first element. (Doesn't work, always set from command line.)
 * formname - name of the form, used for naming instances, submissions etc.
   By default name of the element. (Ugly if element name contains namespace,
   set from command line if possible.)
 * url - URL where to submit the result, by default file 'formname.xml'.
 * method - submission method, by default 'put'.

WSDL2XForms
-----------

wsdl2xforms.bat wsdlpath xformspath "param1=value" "param2=value"

Arguments:
 * wsdlpath - path to WSDL file.
 * xformspath - path where to generate XForms files. Must be path to file,
   while only directory part is used. File may be non-existent.

Parameters (in addition to Schema2XForms parameters):
 * debug - if true, then prints out tons of debugging information.
   By default false.
 * debugurl - URL for showing the XML content of request, by default
   debug-instance.jsp.
 * urlxml - URL for showing the XML content of response, by default
   return-instance.jsp.
 * url - URL where to submit the result, by default soap:address/@location.
   (Not implemented yet)
 * method - submission method, by default 'post'.

Xtee2XForms
-----------

xtee2xforms.bat wsdlpath xformspath "param1=value" "param2=value"

Arguments:
 * wsdlpath - path to WSDL file.
 * xformspath - path where to generate XForms files. Must be path to file,
   while only directory part is used. File may be non-existent. Subdirectory 
   is generated for each producer (which is mostly the name of WSDL file).

Parameters (in addition to WSDL2XForms parameters):
 * debug - if true, then prints out tons of debugging information.
   By default false.
 * operation - name of the operation to generate form for. By default forms for
   all operations are generated.
 * institution - name of the institution performing the query, for testing.
 * idcode - ID code of the person performing the query, for testing.
 * post - post of the person performing the query, for testing.
 * id - query ID, for testing.
 * document - document number, for testing.
 * classifier-prefix - path where classifier files can be found.
 * classifier-suffix - extesion of classifier files, by default ".xml".

Complex2XForms
-----------

complex2xforms.bat wsdlpath xformspath "param1=value" "param2=value"

Arguments:
 * wsdlpath - path to WSDL file.
 * xformspath - path where to generate XForms files. Must be path to file,
   while only directory part is used. File may be non-existent. Subdirectory 
   is generated for each producer (which is mostly the name of WSDL file).

Parameters (in addition to Xtee2XForms parameters):
 * debug - if true, then prints out tons of debugging information.
   By default false.
 * wsdl-prefix - path where WSDL files of simple services can be found.
 * wsdl-suffix - extesion of WSDL files, by default ".wsdl".

Demos
=====

You can find demos in demos directory.

purchaseOrder
-------------

Example of Schema2XForms output. This is purchaseOrder.xsd from Chiba SVN. 
The generated form cannot be directly used in Chiba, as the instance contains 
type declarations, which are unknown to Chiba. There is also slightly modified 
version in purchaseOrder_chiba.xhtml, which should work in Chiba too.

GoogleSearch
------------

Example of WSDL2XForms output. It was the only publicly available WSDL file I 
was able to get. Generator works, but the service itself is unusable, as Google
doesn't provide API keys any more.

mteenus
-------

Example of Xtee2XForms output. Can't be run in current Chiba, as it needs 
special setup. But you can try it at 
http://arendus.tarkvaralabor.ee:8080/chiba-web-xtee/forms/xteeportal/producers/iframe.html

Pay attention to:
 * layout structure follows XML structure,
 * in EHAK section there are 3 combos that depend on each other,
 * there is repeat section in the end, where you can upload files,
 * this form is fully generated from WSDL definition,
 * Chiba is actually in iframe, that is resized as form size changes.

Details
=======

 * Enumerations are turned into select1 controls.
 * Binary fields are turned into upload controls.
 * Complex types are converted into XForms groups.
 * Elements with maxOccurs="unbounded" are converted into repeats.
 * Choices are rendered as radio buttons, which show or hide relevant sections.
 * Element and attribute groups are supported.
 * All (useful) XML Schema restrictions (facets) are supported.
 * XForms labels, alerts and hints can be added under xsd:annotation/xsd:appinfo.

Implementation
==============

The converter takes several passes over it's input to generate different parts
of XForms file. Each pass is implemented as XSLT mode. The main modes are:

 * instance - generates prototype instance
 * bind - generates bindings for validation
 * form - generates form controls

There are many less important modes, so the complete mode tree for WSDL2XForms
looks like this:

* html
  * head
    * title
    * model
      * instance
        * default
        * instance-soap-header
      * lookup
        * lookup-label
      * bind
        * mips
	  * readonly
	  * required
	  * relevant
	  * calculate
	  * constaint
	* nillable
      * submission
        * submission-actions
	  * submission-actions-submit
	  * submission-actions-submit-done
	  * submission-actions-submit-error
	  * submission-actions-submit-error-message
	    * submission-actions-submit-error-message-label
      * activate
  * body
    * heading
    * form
      * label
        * appearance
      * items
        * lookup-label
      * choice
        * choice-label
	  * label-only
      * form-actions
        * form-submit
	* form-fault
	* form-again

All those passes used to have nearly identical code to traverse the XML Schema
elements. So the common code was moved into schematraverse.xsl and 
wsdltraverse.xsl. This allows you to say just <xsl:apply-imports/> to continue
parsing of XML Schema as usual. And it is used a lot in all places.

Current import structure of the files:

  complex2xforms.xsl
         ^
         |

  xtee2xforms.xsl
         ^
         |

  wsdl2xforms.xsl   <-- wsdltraverse.xsl

         ^
         |

  schema2xforms.xsl <-- schematraverse.xsl


Modes are preferred to named templates. If template doesn't apply to any 
particular element, the root element (/) is used as dummy placeholder. This 
pattern makes it easy to extend functionality of existing generators. You can 
import schema2xforms.xsl or wsdl2xforms.xsl into your own script and override 
behavior of processing some elements, as you would do in object-oriented 
language. Instead of calling superclass you say just <xsl:apply-imports/>. 

As with object-oriented design, you have to design for extensibility, eg 
provide "hooks" in certain places. The design of generator attempts to do that,
but it's far from being perfect. The extensibility mechanism has been 
field-tested with xtee2xforms.xsl and complex2xforms.xsl, so it's at least one 
step further from being just an idea.
