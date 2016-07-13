<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xi="http://www.w3.org/2001/XInclude"
		xmlns:csd="urn:ihe:iti:csd:2013"
		xmlns:xforms = "http://www.w3.org/2002/xforms"
		xmlns="urn:ihe:iti:csd:2013"
		>
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
  
  <xsl:template match="/">
    <html>
      <head>
        <style type="text/css">
          div {
          border-radius: 1em 1em 1em 1em;
          }
          .function {
          background-color: #feedff;
          width:90%;
          magin-top:2em;
          padding-bottom:1em;
          padding-left:1em;
	  box-shadow:0 6px 2px 0 #CCCCCC;
          }
	  .source {
	  overflow:auto;
	  }
          .attribute{
          border-radius: 1em 1em 1em 1em;
          background-color: #FBFBEF;                    
          font-style: italic;
          font-weight: lighter;
          height: auto;
          float:right;
          margin-right:2em;
          margin-left: 1em;
          padding: 2em;
	  box-shadow:0 4px 2px 0 #CCCCCC;
          }
          .callout{
          background: none repeat scroll 0 0 #EEEEEE;
          margin: 1em;
          overflow: auto;
          padding: 1em 2em;
          width: auto;
	  box-shadow:0 6px 2px 0 #CCCCCC;
          }
          .callout h2 {
          background-color: #EEFFFF;
          border-radius: 0.5em 0.5em 0.5em 0.5em;
          padding: 0.2em 0.2em 0.2em 1em;
          }
          pre {
          font-family: "Courier New",Courier,monospace;
          font-size: 0.8em;
	  overflow:scroll;
          }
	  li i.urn {
	  display:inline-block;
	  min-width:18em;
	  max-width:18em;
	  width:18em;
	  }
        </style> 
      </head>
      <body>
        <div class="function">
          <h2>Stored Functions</h2>
          <ul>
            <xsl:for-each select="//csd:careServicesFunction">
              <li>
                <i class='urn'>  <xsl:value-of select="@urn"/> </i>
                <a style='position:relative;left:2em'>
                  <xsl:attribute name="href"><xsl:text>#</xsl:text><xsl:value-of select='@urn'/></xsl:attribute>
                  <xsl:value-of select="substring(csd:description,1,100)"/>
		  <xsl:if test="string-length(csd:description) > 100">...</xsl:if>
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </div>
        <xsl:for-each select="//csd:careServicesFunction">
          <xsl:call-template name="CareServicesConsumerFunction">
            <xsl:with-param name="func" select="."/> 
          </xsl:call-template>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="CareServicesConsumerFunction">
    <xsl:param name="func" />
    <a><xsl:attribute name="id"><xsl:value-of select='@urn'/></xsl:attribute></a>          
    
    <div class="function">
      <div class="callout">
        <span class='attribute'>Content-Type: 
        <xsl:choose>
          <xsl:when test="@content-type"><xsl:value-of select="@content-type"/></xsl:when>
          <xsl:otherwise>text/xml</xsl:otherwise>
        </xsl:choose>
        <br/>
	URN: <xsl:value-of select="@urn"/>
        </span>

	<h2>Description</h2>
	<br/>
	<br/>

	<span class='source'>
	  <pre class='source'>
	    <xsl:value-of select="$func/csd:description"/>
	  </pre>
	</span> 
        
	<h2>Definition            </h2>
	<span class='source'>Source: 
	<pre><xsl:value-of select="$func/csd:definition"/></pre>
	</span>

      </div>
    </div>
  </xsl:template>
  
  
  
  
  <xsl:template name='escape-xml-node'>
    <xsl:choose>
      <xsl:when test="self::text()">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="self::comment()">
        <xsl:text>&lt;!--</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>--&gt;</xsl:text>                
      </xsl:when>               
      <xsl:when test="self::node() and name()">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:for-each select="@*">
          <xsl:text> </xsl:text>
          <xsl:value-of select="local-name()"/>
          <xsl:text>="</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>"</xsl:text>
        </xsl:for-each>
        <xsl:text>&gt;</xsl:text>
        <xsl:for-each select="child::node()">
          <xsl:call-template name='escape-xml-node'/>
        </xsl:for-each>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="local-name()"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name='remove-namespace'>
    <xsl:choose>
      <xsl:when test="self::text()">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{local-name()}" namespace="">
          <xsl:apply-templates/>  
        </xsl:element>     
      </xsl:otherwise>           
    </xsl:choose>
  </xsl:template>
  
  
  
  <xsl:template match="*">
    <xsl:element name="{name()}" namespace="">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
