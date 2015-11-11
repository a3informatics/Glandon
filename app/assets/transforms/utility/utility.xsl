<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:a="http://www.assero.co.uk/"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="quote">"</xsl:variable>
    
    <!-- Subject -->
    <xsl:template name="Subject">
        <xsl:param name="pName"/>
        <xsl:value-of select="concat($pName,'&#xa;')"/>
    </xsl:template>

    <!-- Object and predicate -->
    <xsl:template name="PredicateObject">
        <xsl:param name="pPredicateName"/>
        <xsl:param name="pObjectName"/>
        <xsl:value-of select="concat('&#009;',$pPredicateName,' ',$pObjectName,' ;','&#xa;')"/>
    </xsl:template>

    <!-- Subject end -->
    <xsl:template name="SubjectEnd">
        <xsl:value-of select="concat('.','&#xa;')"/>
    </xsl:template>

    <!-- Create ScopedIdentifier -->
    <xsl:template name="ScopedIdentifier">
        <xsl:param name="pCID"/>
        <xsl:param name="pIdentifier"/>
        <xsl:param name="pVersionLabel"/>
        <xsl:param name="pVersion"/>
        <xsl:param name="pScope"/>
        <xsl:call-template name="Subject">
            <xsl:with-param name="pName" select="concat('mdrItems:',$pCID)"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'rdf:type'"/>
            <xsl:with-param name="pObjectName" select="'isoI:ScopedIdentifier'"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoI:identifier'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pIdentifier,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoI:versionLabel'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pVersionLabel,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoI:version'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pVersion,$quote,'^^xsd:positiveInteger')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoI:hasScope'"/>
            <xsl:with-param name="pObjectName" select="concat('mdrItems:',$pScope)"/>
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/>
    </xsl:template>

    <xsl:template name="extractBRIDGDatatype">
        <xsl:param name="pType"/>
        <xsl:choose>
            <xsl:when test="substring($pType,1,5)='DSET('">
                <xsl:variable name="Len" select="string-length($pType)-6"/>
                <xsl:value-of select="substring($pType,6,$Len)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="Amend1" select="translate($pType,')','')"/>
                <xsl:variable name="Amend2" select="translate($Amend1,'(','-')"/>
                <xsl:value-of select="$Amend2"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="extractBRIDGDatatype2">
        <xsl:param name="pType"/>
        <xsl:choose>
            <xsl:when test="substring($pType,1,5)='DSET('">
                <xsl:variable name="Len" select="string-length($pType)-6"/>
                <xsl:value-of select="substring($pType,6,$Len)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="Amend1" select="translate($pType,')','')"/>
                <xsl:variable name="Amend2" select="translate($Amend1,'(','_')"/>
                <xsl:variable name="Amend3" select="translate($Amend2,'.','')"/>
                <xsl:variable name="Amend4" select="translate($Amend3,'-','_')"/>
                <xsl:value-of select="$Amend4"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="RootSDTMName">
        <xsl:param name="pName"/>
        <xsl:choose>
            <xsl:when test="$pName='DOMAIN'">
                <xsl:value-of select="$pName"/>
            </xsl:when>
            <xsl:when test="$pName='USUBJID'">
                <xsl:value-of select="$pName"/>
            </xsl:when>
            <xsl:when test="$pName='AGE'">
                <xsl:value-of select="$pName"/>
            </xsl:when>
            <xsl:when test="$pName='SEX'">
                <xsl:value-of select="$pName"/>
            </xsl:when>
            <xsl:when test="$pName='COUNTRY'">
                <xsl:value-of select="$pName"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="Len" select="string-length($pName)"/>
                <xsl:value-of select="concat('--',substring($pName,3,$Len))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
