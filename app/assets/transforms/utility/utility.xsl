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

    <!-- Managed Items common fields -->
    <xsl:template name="CommonFields">
        <xsl:param name="pDate"/>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:origin'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:changeDescription'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:creationDate'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pDate,$quote,'^^xsd:date')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:lastChangeDate'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pDate,$quote,'^^xsd:date')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:explanatoryComment'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$quote,'^^xsd:string')"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Managed Items common fields -->
    <xsl:template name="CommonFieldsV2">
        <xsl:param name="pDate"/>
        <xsl:param name="pComment"/>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:origin'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:changeDescription'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pComment,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:creationDate'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pDate,$quote,'^^xsd:date')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:lastChangeDate'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pDate,$quote,'^^xsd:date')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoT:explanatoryComment'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$quote,'^^xsd:string')"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Create ScopedIdentifier -->
    <xsl:template name="ScopedIdentifier">
        <xsl:param name="pCID"/>
        <xsl:param name="pIdentifier"/>
        <xsl:param name="pVersionLabel"/>
        <xsl:param name="pVersion"/>
        <xsl:param name="pSemanticVersion"/>
        <xsl:param name="pScope"/>
        <xsl:call-template name="Subject">
            <xsl:with-param name="pName" select="concat(':',$pCID)"/>
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
            <xsl:with-param name="pPredicateName" select="'isoI:semantic_version'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pSemanticVersion,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoI:hasScope'"/>
            <xsl:with-param name="pObjectName" select="concat('mdrItems:',$pScope)"/>
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/>
    </xsl:template>

    <!-- Create Registration identifier -->
    <xsl:template name="RegistrationState">
        <xsl:param name="pCID"/>
        <xsl:param name="pRA"/>
        <xsl:param name="pUntilDate"/>
        <xsl:param name="pEffectiveDate"/>
        <xsl:call-template name="Subject">
            <xsl:with-param name="pName" select="concat(':',$pCID)"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'rdf:type'"/>
            <xsl:with-param name="pObjectName" select="'isoR:RegistrationState'"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoR:registrationStatus'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'Standard',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoR:administrativeNote'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoR:effectiveDate'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pEffectiveDate,'T00:00:00Z',$quote,'^^xsd:dateTime')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoR:untilDate'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pUntilDate,'T00:00:00Z',$quote,'^^xsd:dateTime')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoR:unresolvedIssue'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoR:administrativeStatus'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoR:previousState'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'Qualified',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoR:byAuthority'"/>
            <xsl:with-param name="pObjectName" select="concat('mdrItems:',$pRA)"/>
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/>
    </xsl:template>
 
    <!-- Create Operational Reference -->
    <xsl:template name="OperationalReference">
        <xsl:param name="pCID"/>
        <xsl:param name="pType"/>
        <xsl:param name="pLabel"/>
        <xsl:param name="pRefType"/>
        <xsl:param name="pRef"/>
        <xsl:param name="pOrdinal"/>
        <xsl:param name="pEnabled"/>
        <xsl:param name="pOptional"/>
        <xsl:param name="pLocalLabel"/>
        <xsl:call-template name="Subject">
            <xsl:with-param name="pName" select="$pCID"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'rdf:type'"/>
            <xsl:with-param name="pObjectName" select="concat('bo:',$pType)"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'rdfs:label'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pLabel,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="concat('bo:',$pRefType)"/>
            <xsl:with-param name="pObjectName" select="$pRef"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bo:ordinal'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pOrdinal,$quote,'^^xsd:positiveInteger')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bo:enabled'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pEnabled,$quote,'^^xsd:boolean')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bo:optional'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pOptional,$quote,'^^xsd:boolean')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bo:local_label'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,$pLocalLabel,$quote,'^^xsd:string')"/>
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
