<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:a="http://www.assero.co.uk/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:import href="../../utility/utility.xsl" />
    
    <!-- Constants -->
    <xsl:variable name="LT">&lt;</xsl:variable>
    <xsl:variable name="GT">&gt;</xsl:variable>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="quote">"</xsl:variable>
    
    <!-- Text document (.ttl Turtle) -->
    <xsl:output method="text"/>
    
    <!-- Match the root element -->
    <xsl:template match="/">
        
        <!-- Build the document header with all prefixes etc -->
        <!-- First the base URI and imports -->
        <xsl:value-of select="concat('# baseURI: ','http://www.assero.co.uk/MDRCDISCSDTM&#xa;')"/>
        <xsl:text># imports: http://www.assero.co.uk/CDISCSDTM&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        
        <!-- Now the prefixes -->
        <xsl:text disable-output-escaping="yes">@prefix : &lt;http://www.assero.co.uk/MDRModels/V1#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix bd: &lt;http://www.assero.co.uk/BusinessDomain#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix cbc: &lt;http://www.assero.co.uk/CDISCBiomedicalConcept#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoI: &lt;http://www.assero.co.uk/ISO11179Identification#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoR: &lt;http://www.assero.co.uk/ISO11179Registration#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoT: &lt;http://www.assero.co.uk/ISO11179Types#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix owl: &lt;http://www.w3.org/2002/07/owl#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt; .&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>
        
        <!-- Header and imports-->
        <xsl:text disable-output-escaping="yes">&lt;http://www.assero.co.uk/MDRCDISCSDTM&gt;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;rdf:type owl:Ontology ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.assero.co.uk/CDISCSDTM&gt; ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">.&#xa;</xsl:text>
        
        <xsl:call-template name="Model">
            <xsl:with-param name="pNode" select="//a:Model"/>
        </xsl:call-template>
        
        <xsl:variable name="identifierVariables" select="//a:Model/a:Class[@Name='http://rdf.cdisc.org/std/sdtm-1-2#IdentifierVariables']/a:Variable"/>
        <xsl:variable name="eventVariables" select="//a:Model/a:Class[@Name='http://rdf.cdisc.org/std/sdtm-1-2#EventVariables']/a:Variable"/>
        <xsl:variable name="interventionVariables" select="//a:Model/a:Class[@Name='http://rdf.cdisc.org/std/sdtm-1-2#InterventionVariables']/a:Variable"/>
        <xsl:variable name="findingVariables" select="//a:Model/a:Class[@Name='http://rdf.cdisc.org/std/sdtm-1-2#FindingVariables']/a:Variable"/>
        <xsl:variable name="timingVariables" select="//a:Model/a:Class[@Name='http://rdf.cdisc.org/std/sdtm-1-2#TimingVariables']/a:Variable"/>
        <xsl:call-template name="Class">
            <xsl:with-param name="pLabel" select="'Events Observation Class'"/>
            <xsl:with-param name="pIdentifier" select="'EVENTS'"/>
            <xsl:with-param name="pIdentifierVariables" select="$identifierVariables"/>
            <xsl:with-param name="pTimingVariables" select="$timingVariables"/>
            <xsl:with-param name="pVariables" select="$eventVariables"/>
            <xsl:with-param name="pNode" select="//a:Model"/>
        </xsl:call-template>         
        <xsl:call-template name="Class">
            <xsl:with-param name="pLabel" select="'Interventions Observation Class'"/>
            <xsl:with-param name="pIdentifier" select="'INTERVENTIONS'"/>
            <xsl:with-param name="pIdentifierVariables" select="$identifierVariables"/>
            <xsl:with-param name="pTimingVariables" select="$timingVariables"/>
            <xsl:with-param name="pVariables" select="$interventionVariables"/>
            <xsl:with-param name="pNode" select="//a:Model"/>
        </xsl:call-template>         
        <xsl:call-template name="Class">
            <xsl:with-param name="pLabel" select="'FINDINGS Observation Class'"/>
            <xsl:with-param name="pIdentifier" select="'FINDINGS'"/>
            <xsl:with-param name="pIdentifierVariables" select="$identifierVariables"/>
            <xsl:with-param name="pTimingVariables" select="$timingVariables"/>
            <xsl:with-param name="pVariables" select="$findingVariables"/>
            <xsl:with-param name="pNode" select="//a:Model"/>
        </xsl:call-template>

        <xsl:for-each select="$identifierVariables">
            <xsl:sort select="@Ordinal"/>
            <xsl:call-template name="Variable"> 
                <xsl:with-param name="pVariable" select="." /> 
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="$timingVariables">
            <xsl:sort select="@Ordinal"/>
            <xsl:call-template name="Variable"> 
                <xsl:with-param name="pVariable" select="." /> 
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="$eventVariables">
            <xsl:sort select="@Ordinal"/>
            <xsl:call-template name="Variable"> 
                <xsl:with-param name="pVariable" select="." /> 
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="$interventionVariables">
            <xsl:sort select="@Ordinal"/>
            <xsl:call-template name="Variable"> 
                <xsl:with-param name="pVariable" select="." /> 
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="$findingVariables">
            <xsl:sort select="@Ordinal"/>
            <xsl:call-template name="Variable"> 
                <xsl:with-param name="pVariable" select="." /> 
            </xsl:call-template>
        </xsl:for-each>
        
        
    </xsl:template>
    
    <xsl:template name="Model">
        <xsl:param name="pNode"/>
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="':M-CDISC_SDTM'" /> 
        </xsl:call-template>
        <xsl:call-template name="ManagedItem">
            <xsl:with-param name="pType" select="'bd:Model'"/>
            <xsl:with-param name="pLabel" select="$pNode/@Label"/>
            <xsl:with-param name="pDesc" select="'As issued by CDISC'"/>
            <xsl:with-param name="pOrigin" select="concat('See the equivalent PDF document: SDTM Version ', $pNode/@VersionLabel)"/>
            <xsl:with-param name="pComment" select="''"/>
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'bd:includesTabulation'" /> 
            <xsl:with-param name="pObjectName" select="':M_CDISC_SDTM_EVENTS'" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'bd:includesTabulation'" /> 
            <xsl:with-param name="pObjectName" select="':M_CDISC_SDTM_INTERVENTIONS'" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'bd:includesTabulation'" /> 
            <xsl:with-param name="pObjectName" select="':M_CDISC_SDTM_FINDINGS'" /> 
        </xsl:call-template>
        
        <xsl:variable name="SIName" select="concat('SI-CDISC_SDTM-',$pNode/@Version)"/>
        <xsl:variable name="RSName" select="concat('RS-CDISC_SDTM-',$pNode/@Version)"/>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoI:hasIdentifier'" /> 
            <xsl:with-param name="pObjectName" select="concat('mdrItems:',$SIName)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoR:hasState'" /> 
            <xsl:with-param name="pObjectName" select="concat('mdrItems:',$RSName)" /> 
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/>
        
        <!-- Scoped Identifier -->
        <xsl:call-template name="ScopedIdentifier">
            <xsl:with-param name="pCID" select="$SIName"/>
            <xsl:with-param name="pIdentifier" select="'SDTM Model'"/>
            <xsl:with-param name="pVersionLabel" select="$pNode/@VersionLabel"/>
            <xsl:with-param name="pVersion" select="$pNode/@Version"/>
            <xsl:with-param name="pScope" select="'NS-CDISC'"/>
        </xsl:call-template>
        
        <!-- Registration State -->
        <xsl:call-template name="RegistrationState">
            <xsl:with-param name="pCID" select="$RSName"/>
            <xsl:with-param name="pRA" select="'RA-084433759'"/>
            <xsl:with-param name="pEffectiveDate" select="$pNode/@Date"/>
            <xsl:with-param name="pUntilDate" select="'2100-01-01'"/>
        </xsl:call-template>  
    </xsl:template>
    
    <xsl:template name="Class">     
        <xsl:param name="pLabel"/>      
        <xsl:param name="pIdentifier"/>      
        <xsl:param name="pVariables"/>      
        <xsl:param name="pIdentifierVariables"/>      
        <xsl:param name="pTimingVariables"/> 
        <xsl:param name="pNode"/> 
        
        <xsl:variable name="CIDMinusPrefix" select="concat('CDISC_SDTM_',$pIdentifier)"/>
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="concat('M-',$CIDMinusPrefix)"/> 
        </xsl:call-template>
        <xsl:call-template name="ManagedItem">
            <xsl:with-param name="pType" select="'bd:ClassDomain'"/>
            <xsl:with-param name="pLabel" select="''"/>
            <xsl:with-param name="pDesc" select="''"/>
            <xsl:with-param name="pOrigin" select="''"/>
            <xsl:with-param name="pComment" select="''"/>
        </xsl:call-template>

        <xsl:for-each select="$pIdentifierVariables">
            <xsl:sort select="@Ordinal"/>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'bd:includesColumn'" /> 
                <xsl:with-param name="pObjectName" select="concat(':M-CDISC_SDTM_',replace(@Name,'-',''))" /> 
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="$pVariables">
            <xsl:sort select="@Ordinal"/>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'bd:includesColumn'" /> 
                <xsl:with-param name="pObjectName" select="concat(':M-CDISC_SDTM_',replace(@Name,'-',''))" /> 
            </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="$pTimingVariables">
            <xsl:sort select="@Ordinal"/>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'bd:includesColumn'" /> 
                <xsl:with-param name="pObjectName" select="concat(':M-CDISC_SDTM_',replace(@Name,'-',''))" /> 
            </xsl:call-template>
        </xsl:for-each>
        
        
        <xsl:variable name="SIName" select="concat('SI-',$CIDMinusPrefix,'-',$pNode/@Version)"/>
        <xsl:variable name="RSName" select="concat('RS-',$CIDMinusPrefix,'-',$pNode/@Version)"/>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoI:hasIdentifier'" /> 
            <xsl:with-param name="pObjectName" select="concat('mdrItems:',$SIName)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoR:hasState'" /> 
            <xsl:with-param name="pObjectName" select="concat('mdrItems:',$RSName)" /> 
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/>
        
        <!-- Scoped Identifier -->
        <xsl:call-template name="ScopedIdentifier">
            <xsl:with-param name="pCID" select="$SIName"/>
            <xsl:with-param name="pIdentifier" select="concat('SDTM ',$pIdentifier,' Model')"/>
            <xsl:with-param name="pVersionLabel" select="$pNode/@VersionLabel"/>
            <xsl:with-param name="pVersion" select="$pNode/@Version"/>
            <xsl:with-param name="pScope" select="'NS-CDISC'"/>
        </xsl:call-template>
        
        <!-- Registration State -->
        <xsl:call-template name="RegistrationState">
            <xsl:with-param name="pCID" select="$RSName"/>
            <xsl:with-param name="pRA" select="'RA-084433759'"/>
            <xsl:with-param name="pEffectiveDate" select="$pNode/@Date"/>
            <xsl:with-param name="pUntilDate" select="'2100-01-01'"/>
        </xsl:call-template>  
    </xsl:template>
        
    <xsl:template name="Variable">
        <xsl:param name="pVariable"/>
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="concat(':M-CDISC_SDTM_',replace(@Name,'-',''))"/> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
            <xsl:with-param name="pObjectName" select="'bd:Column'" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdfs:label'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,@Label,$quote,'^^xsd:string')"/> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'bd:name'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,@Name,$quote,'^^xsd:string')"/> 
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="substring(@Name,1,1) = '-'">
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="'bd:prefixed'" /> 
                    <xsl:with-param name="pObjectName" select="concat($quote,'true',$quote,'^^xsd:boolean')"/> 
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="'bd:prefixed'" /> 
                    <xsl:with-param name="pObjectName" select="concat($quote,'false',$quote,'^^xsd:boolean')"/> 
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'bd:description'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,@Description,$quote)"/> 
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/>     
    </xsl:template>

    <xsl:template name="ManagedItem">
        <xsl:param name="pType"/>
        <xsl:param name="pLabel"/>
        <xsl:param name="pDesc"/>
        <xsl:param name="pOrigin"/>
        <xsl:param name="pComment"/>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
            <xsl:with-param name="pObjectName" select="$pType" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdfs:label'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,$pLabel,$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoT:ChangeDescription'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,$pDesc,$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoT:Origin'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,$pOrigin,$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoT:explanatoryComment'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,$pComment,$quote,'^^xsd:string')" /> 
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>