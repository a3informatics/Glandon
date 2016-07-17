<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sr="http://www.w3.org/2005/sparql-results#"
    xmlns="http://www.assero.co.uk/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:param name="UseVersion"/>
    <xsl:variable name="Entry" select="/Manifest/Model[@VersionLabel=$UseVersion]"/>
    
    <xsl:template match="/">
        <xsl:variable name="Filename" select="$Entry/@Filename"/>
        <xsl:variable name="Document" select="document($Filename)"/>
        <xsl:apply-templates select="$Document/sr:sparql"/>
    </xsl:template>
    
    <xsl:template match="sr:sparql">
        <xsl:variable name="classes" select="distinct-values(sr:results/sr:result/sr:binding[@name='context']/sr:uri)"/>
        <xsl:variable name="variables" select="sr:results/sr:result"/>
        <Model>
            <xsl:attribute name="Label">
                <xsl:value-of select="$Entry/@Label"/>
            </xsl:attribute>
            <xsl:attribute name="Version">
                <xsl:value-of select="$Entry/@Version"/>
            </xsl:attribute>
            <xsl:attribute name="VersionLabel">
                <xsl:value-of select="$Entry/@VersionLabel"/>
            </xsl:attribute>
            <xsl:attribute name="Date">
                <xsl:value-of select="$Entry/@Date"/>
            </xsl:attribute>
            <xsl:for-each select="$classes">
                <Class>
                    <xsl:variable name="name" select="."/>
                    <xsl:attribute name="Name">
                        <xsl:value-of select="$name"/>
                    </xsl:attribute>
                    <xsl:variable name="classVariables" select="$variables[sr:binding[@name='context']/sr:uri = $name]" />
                    <xsl:for-each select="$classVariables">
                        <xsl:call-template name="processVariable">
                            <xsl:with-param name="pVariable" select="."/>                            
                        </xsl:call-template>
                    </xsl:for-each>
                </Class>
            </xsl:for-each>    
        </Model>
    </xsl:template>
    
    <xsl:template name="processVariable">
        <xsl:param name="pVariable"/>
        <Variable>
            <xsl:attribute name="Ordinal">
                <xsl:value-of select="$pVariable/sr:binding[@name='ord']/sr:literal"/>
            </xsl:attribute>
            <xsl:attribute name="Name">
                <xsl:value-of select="$pVariable/sr:binding[@name='name']/sr:literal"/>
            </xsl:attribute>
            <xsl:attribute name="Label">
                <xsl:value-of select="$pVariable/sr:binding[@name='label']/sr:literal"/>
            </xsl:attribute>
            <xsl:attribute name="Type">
                <xsl:value-of select="$pVariable/sr:binding[@name='type_def']/sr:uri"/>
            </xsl:attribute>
            <xsl:attribute name="Role">
                <xsl:value-of select="$pVariable/sr:binding[@name='role']/sr:literal"/>
            </xsl:attribute>
            <xsl:attribute name="Description">
                <xsl:value-of select="$pVariable/sr:binding[@name='desc']/sr:literal"/>
            </xsl:attribute>
        </Variable>
    </xsl:template>
    
</xsl:stylesheet>