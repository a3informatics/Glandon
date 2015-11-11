<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:sr="http://www.w3.org/2005/sparql-results#"
    xmlns="http://www.assero.co.uk/" exclude-result-prefixes="xs" version="1.0">

    <xsl:import href="../../utility/utility.xsl"/>

    <!-- 
        Parameters
        SDTMVersion:        The CDISC version of the SDTM IG being created.
        InternalVersion:    The internal version of the SDTM IG being created.
        IGNamespace:        The namespace to be used with the turtle document for the SDTM IG Standard being created.
        DNamespace:         The namespace to be used with the turtle document for the Domains being created.
    -->
    <xsl:param name="SDTMVersion"/>
    <xsl:param name="InternalVersion"/>
    <xsl:param name="IGNamespace"/>
    <xsl:param name="DNamespace"/>

    <!-- Text document (.ttl Turtle) -->
    <xsl:output method="text"/>
    <xsl:output omit-xml-declaration="yes" indent="no"/>

    <!-- Constants -->
    <xsl:variable name="newline" select="'&#x0A;'"/>
    <xsl:variable name="tab" select="'&#x09;'"/>
    <xsl:variable name="lt">&lt;</xsl:variable>
    <xsl:variable name="gt">&gt;</xsl:variable>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="quote">"</xsl:variable>
    <xsl:variable name="DPrefix">D-</xsl:variable>
    <xsl:variable name="VPrefix">V-</xsl:variable>
    <xsl:variable name="DomainNSPrefix" select="concat('mdrDomainsV', $InternalVersion)"/>
    <xsl:variable name="CID" select="'STD-CDISC_SDTM_IG'"/>
    <xsl:variable name="domains"/>

    <!-- Match the root element -->
    <xsl:template match="sr:sparql">

        <!-- Build the document header with all prefixes etc -->

        <!-- First the base URI and imports -->
        <xsl:value-of select="concat('# baseURI: ',$IGNamespace,$newline)"/>
        <xsl:text># imports: http://www.assero.co.uk/ISO11179Identification&#xa;</xsl:text>
        <xsl:text># imports: http://www.assero.co.uk/BusinessDomain&#xa;</xsl:text>
        <xsl:text># imports: http://www.assero.co.uk/BusinessStandard&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>

        <!-- Now the prefixes -->
        <xsl:value-of disable-output-escaping="yes" select="concat('@prefix : &lt;',$IGNamespace,'#&gt; .&#xa;')"/>
        <xsl:value-of disable-output-escaping="yes" select="concat('@prefix ',$DomainNSPrefix,': &lt;',$DNamespace,'#&gt; .&#xa;')"/>
        <xsl:text disable-output-escaping="yes">@prefix isoB: &lt;http://www.assero.co.uk/ISO11179Basic#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoI: &lt;http://www.assero.co.uk/ISO11179Identification#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix bo: &lt;http://www.assero.co.uk/BusinessOperational#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix bd: &lt;http://www.assero.co.uk/BusinessDomain#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix bs: &lt;http://www.assero.co.uk/BusinessStandard#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrItems: &lt;http://www.assero.co.uk/MDRItems#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix owl: &lt;http://www.w3.org/2002/07/owl#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix skos: &lt;http://www.w3.org/2004/02/skos/core#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt; .&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>

        <!-- Header and imports-->
        <xsl:value-of disable-output-escaping="yes" select="concat('&lt;',$IGNamespace,'&gt;&#xa;')"/>
        <xsl:text>&#009;rdf:type owl:Ontology ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.assero.co.uk/ISO11179Identification&gt; ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.assero.co.uk/BusinessDomain&gt; ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.assero.co.uk/BusinessStandard&gt; ;&#xa;</xsl:text>
        <xsl:text>.&#xa;</xsl:text>

        <!-- Build the SDTM IG entry -->
        <xsl:variable name="SICID" select="concat('SI-CDISC_SDTM_IG-',$InternalVersion)"/>
        <xsl:call-template name="Subject">
            <xsl:with-param name="pName" select="concat(':',$CID)"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'rdf:type'"/>
            <xsl:with-param name="pObjectName" select="'bs:SDTMIG'"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bo:name'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'CDISC SDTM Implementation Guide',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'isoI:hasIdentifier'"/>
            <xsl:with-param name="pObjectName" select="concat('mdrItems:',$SICID)"/>
        </xsl:call-template>
        
        <!-- Build list of domains. Will have repeats. -->
        <xsl:variable name="domains" select="sr:results/sr:result/sr:binding[@name='domainName']/sr:literal"/>
        
        <!-- Add links from standard to domains -->
        <xsl:for-each select="$domains[not(.=preceding::*)]">
            <xsl:variable name="DomainName" select="."/>
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="'bs:composedOf'"/>
                <xsl:with-param name="pObjectName" select="concat($DomainNSPrefix,':',$DPrefix,$DomainName)"/>
            </xsl:call-template>
        </xsl:for-each>
        
        <!-- Close the standard off, end of subject-->
        <xsl:call-template name="SubjectEnd"/>
        
        <!-- Build the ScopedIdentifier for the Standard -->
        <xsl:call-template name="ScopedIdentifier">
            <xsl:with-param name="pCID" select="$SICID"/>
            <xsl:with-param name="pIdentifier" select="'CDISC SDTM Implementation Guide'"/>
            <xsl:with-param name="pVersionLabel" select="$SDTMVersion"/>
            <xsl:with-param name="pVersion" select="$InternalVersion"/>
            <xsl:with-param name="pScope" select="'NS-CDISC'"/>
        </xsl:call-template>    
        
        <!-- Process each domain and create the domain entries -->
        <xsl:call-template name="domains">
            <xsl:with-param name="pDomains" select="$domains"/>
        </xsl:call-template>
        
        <!-- Process each variable -->
        <xsl:apply-templates select="sr:results/sr:result/sr:binding[@name='name']"/>
    </xsl:template>

    <xsl:template name="domains">
        <xsl:param name="pDomains"/>
        <xsl:param name="pSDTMVersion"/>
        <xsl:for-each select="$pDomains[not(.=preceding::*)]">
            <xsl:variable name="DomainName" select="."/>
            <xsl:variable name="SICID" select="concat('SI-DOMAIN_',$DomainName,'-',$InternalVersion)"/>
            <xsl:call-template name="Subject">
                <xsl:with-param name="pName" select="concat($DomainNSPrefix,':',$DPrefix,$DomainName)"/>
            </xsl:call-template>
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="'rdf:type'"/>
                <xsl:with-param name="pObjectName" select="'bd:Domain'"/>
            </xsl:call-template>
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="'bo:name'"/>
                <xsl:with-param name="pObjectName" select="concat($quote,$DomainName,$quote,'^^xsd:string')"/>
            </xsl:call-template>
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="'rdfs:label'"/>
                <xsl:with-param name="pObjectName" select="concat($quote,'SDTM Domain',$quote,'^^xsd:string')"/>
            </xsl:call-template>
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="'isoI:hasIdentifier'"/>
                <xsl:with-param name="pObjectName" select="concat('mdrItems:',$SICID)"/>
            </xsl:call-template>
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="'bs:usedBy'"/>
                <xsl:with-param name="pObjectName" select="concat(':',$CID)"/>
            </xsl:call-template>
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="'bd:basedOn'"/>
                <xsl:with-param name="pObjectName" select="concat($lt,../../sr:binding[@name='dataset']/sr:uri,$gt)"/>
            </xsl:call-template>
            <xsl:call-template name="SubjectEnd"/>
            <xsl:call-template name="ScopedIdentifier">
                <xsl:with-param name="pCID" select="$SICID"/>
                <xsl:with-param name="pIdentifier" select="concat('CDISC SDTM ',$DomainName,' Domain')"/>
                <xsl:with-param name="pVersion" select="$SDTMVersion"/>
                <xsl:with-param name="pInternalVersion" select="$InternalVersion"/>
                <xsl:with-param name="pScope" select="'NS-CDISC'"/>
            </xsl:call-template>           
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="sr:binding[@name='name']">

        <xsl:call-template name="Subject">
            <xsl:with-param name="pName" select="concat(':',$VPrefix,sr:literal)"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'rdf:type'"/>
            <xsl:with-param name="pObjectName" select="'bd:Variable'"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:basedOn'"/>
            <xsl:with-param name="pObjectName" select="concat($lt,../sr:binding[@name='subject']/sr:uri,$gt)"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'rdfs:label'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'SDTM Variable',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:core'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'???',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:datatype'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'???',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:defaultCommentSet'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,false(),$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:defaultComment'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:length'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'NN',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:format'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'???',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:notes'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'???',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:origin'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,@Name,$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:role'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,'???',$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:supplementalQualifier'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,false(),$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject">
            <xsl:with-param name="pPredicateName" select="'bd:used'"/>
            <xsl:with-param name="pObjectName" select="concat($quote,false(),$quote,'^^xsd:string')"/>
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/>

    </xsl:template>

</xsl:stylesheet>
