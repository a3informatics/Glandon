<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mms="http://rdf.cdisc.org/mms#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:cts="http://rdf.cdisc.org/ct/schema#" exclude-result-prefixes="xs" version="1.0">

    <!-- 
        Parameters
        UseVersion:     The version to be transformed. Must exist in the manifest document (the XML being transformed). Used
                        as a key into the document. Should be consistent the namespace provided in the other parameter
        Namespace:      The namespace to be used with the turtle document for the Thesaurus being created.
        SI:             The URI (partial, minus namespace, assumed to be :org) of the ScopedIdentifier for the thesaurus being created.
        CID:            The URI (partial, minus namespace, assumed to be :org) of the thesaurus being created.
    -->
    <xsl:param name="UseVersion"/>
    <xsl:param name="Namespace"/>
    <xsl:param name= "SI"/>
    <xsl:param name= "CID"/>
    
    <!-- Text document (.ttl Turtle) -->
    <xsl:output method="text"/>
    <xsl:output omit-xml-declaration="yes" indent="no"/>
    
    <!-- Constants -->
    <xsl:variable name="newline" select="'&#x0A;'" />
    <xsl:variable name="tab" select="'&#x09;'" />
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="quote">"</xsl:variable>
    <xsl:variable name="CLPrefix">CL-</xsl:variable>
    <xsl:variable name="CLIPrefix">CLI-</xsl:variable>
    <xsl:variable name="ReleaseDate" select="/CDISCTerminology/Update[@version=$UseVersion]/@date"/>
        
    <!-- Match the root element -->
    <xsl:template match="/">

        <!-- Build the document header with all prefixes etc -->

        <!-- First the base URI and imports -->
        <xsl:value-of select="concat('# baseURI: ',$Namespace,$newline)"/>
        <xsl:text># imports: http://www.assero.co.uk/ISO11179Identification&#xa;</xsl:text>
        <xsl:text># imports: http://www.assero.co.uk/ISO25964&#xa;</xsl:text>
        <xsl:text># imports: http://www.w3.org/2004/02/skos/core&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        
        <!-- Now the prefixes -->
        <xsl:value-of disable-output-escaping="yes" select="concat('@prefix : &lt;',$Namespace,'#&gt; .&#xa;')"/>
        <xsl:text disable-output-escaping="yes">@prefix isoB: &lt;http://www.assero.co.uk/ISO11179Basic#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoI: &lt;http://www.assero.co.uk/ISO11179Identification#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix iso25964: &lt;http://www.assero.co.uk/ISO25964#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrItems: &lt;http://www.assero.co.uk/MDRItems#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix owl: &lt;http://www.w3.org/2002/07/owl#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix skos: &lt;http://www.w3.org/2004/02/skos/core#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt; .&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        
        <!-- Header and imports-->
        <xsl:value-of disable-output-escaping="yes" select="concat('&lt;',$Namespace,'&gt;&#xa;')"/>
        <xsl:text>&#009;rdf:type owl:Ontology ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.assero.co.uk/ISO11179Identification&gt; ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.assero.co.uk/ISO25964&gt; ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.w3.org/2004/02/skos/core&gt; ;&#xa;</xsl:text>
        <xsl:text>.&#xa;</xsl:text>
        
        <!-- Build the thesaurus entry -->
        <!-- Now built by the import code -->
        <!--<xsl:value-of select="concat(':',$CID,$newline)"/>
        <xsl:text>&#009;rdf:type iso25964:Thesaurus ;&#xa;</xsl:text>
        <xsl:text>&#009;rdfs:label "CDISC Terminology </xsl:text><xsl:value-of select="$ReleaseDate"/><xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:value-of select="concat('&#009;isoI:hasIdentifier mdrItems:',$SI,' ;',$newline)"/>
        <xsl:text>.&#xa;</xsl:text>-->

        <!-- For each file making up the CDISC Terminology version, select the file set from the catalog file -->
        <xsl:for-each select="/CDISCTerminology/Update[@version=$UseVersion]/File">
            <xsl:apply-templates select="document(@filename)/rdf:RDF"/>
        </xsl:for-each>
    </xsl:template>

    <!-- Template for each file -->
    <xsl:template match="rdf:RDF">

        <!-- Create a node set of all the code list items -->
        <xsl:variable name="ref" select="mms:PermissibleValue/mms:inValueDomain"/>

        <!-- Create each code list -->
        <xsl:for-each select="mms:PermissibleValue">
            <xsl:if test="mms:inValueDomain/mms:EnumeratedValueDomain/cts:nciCode">
                <xsl:variable name="cCode"
                    select="mms:inValueDomain/mms:EnumeratedValueDomain/cts:nciCode"/>
                <xsl:apply-templates select="mms:inValueDomain/mms:EnumeratedValueDomain"/>
                <xsl:value-of select="concat('&#009;','iso25964:narrower :',$CLIPrefix,translate(./@rdf:ID,'.','_'),' ;')"/>
                <xsl:text>&#xa;</xsl:text>
                <xsl:variable name="subref" select="$ref[@rdf:resource=concat('#',$cCode)]"/>
                <xsl:for-each select="$subref">
                    <xsl:value-of select="concat('&#009;','iso25964:narrower :',$CLIPrefix,translate(../@rdf:ID,'.','_'),' ;')"/>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:for-each>
                <xsl:text>.&#xa;</xsl:text>
            </xsl:if>
        </xsl:for-each>

        <!-- Create each code list item -->
        <xsl:for-each select=".">
            <xsl:apply-templates select="mms:PermissibleValue"/>
        </xsl:for-each>

    </xsl:template>

    <!-- Template for the bulk of the code list entry -->
    <xsl:template match="mms:PermissibleValue/mms:inValueDomain/mms:EnumeratedValueDomain">
        <xsl:value-of select="concat(':',$CLPrefix,./cts:nciCode)"/>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>&#009;rdf:type iso25964:ThesaurusConcept ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:identifier "</xsl:text><xsl:value-of select="./cts:nciCode"/><xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:definition "</xsl:text>
        <xsl:value-of select="translate(./cts:cdiscDefinition,$quote,$apos)"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;rdfs:label "</xsl:text>
        <xsl:value-of select="./cts:codelistName"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:notation "</xsl:text>
        <xsl:value-of select="cts:cdiscSubmissionValue"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:preferredTerm "</xsl:text>
        <xsl:value-of select="cts:nciPreferredTerm"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:synonym "</xsl:text>
        <xsl:value-of select="cts:cdiscSynonyms"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:extensible "</xsl:text>
        <xsl:value-of select="cts:isExtensibleCodelist"/>
        <xsl:text>"^^xsd:boolean ;&#xa;</xsl:text>
        <xsl:value-of select="concat('&#009;','iso25964:inScheme :',$CID,' ;',$newline)"/>
    </xsl:template>

    <!-- Template for the code list item entry -->
    <xsl:template match="mms:PermissibleValue">
        <xsl:value-of select="concat(':',$CLIPrefix,translate(./@rdf:ID,'.','_'))"/>
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>&#009;rdf:type iso25964:ThesaurusConcept ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:identifier "</xsl:text>
        <xsl:value-of select="./cts:nciCode"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;rdfs:label "</xsl:text>
        <xsl:value-of select="./cts:nciPreferredTerm"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:definition "</xsl:text>
        <xsl:value-of select="translate(./cts:cdiscDefinition,$quote,$apos)"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:preferredTerm "</xsl:text>
        <xsl:value-of select="./cts:nciPreferredTerm"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:synonym "</xsl:text>
        <xsl:value-of select="translate(./cts:cdiscSynonyms,$quote,$apos)"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>&#009;iso25964:notation "</xsl:text>
        <xsl:value-of select="cts:cdiscSubmissionValue"/>
        <xsl:text>"^^xsd:string ;&#xa;</xsl:text>
        <xsl:text>.&#xa;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
