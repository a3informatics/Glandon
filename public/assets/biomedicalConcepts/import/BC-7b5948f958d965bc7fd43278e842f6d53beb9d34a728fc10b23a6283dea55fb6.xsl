<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:a="http://www.assero.co.uk/"
    exclude-result-prefixes="xs" version="2.0">

    <xsl:import href="../../utility/utility.xsl" />
    
    <!-- Constants -->
    <xsl:variable name="LT">&lt;</xsl:variable>
    <xsl:variable name="GT">&gt;</xsl:variable>
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="quote">"</xsl:variable>
    <xsl:variable name="URIPrefix">BC</xsl:variable>
    <xsl:variable name="MainSeparator">-</xsl:variable>
    <xsl:variable name="MinorSeparator">_</xsl:variable>
    <xsl:variable name="PathSeparator">.</xsl:variable>
    <xsl:variable name="BRIDGDocument" select="document('../../bridg/import/bridg.xml')"/>
    <xsl:variable name="DatatypeDocument" select="document('../../iso21090/import/iso21090.xml')"/>
    
    <!-- Remove version suffix. Namespace will have version in it. Not required. -->
    <xsl:variable name="URIFinish" select="''"/>
    
    <!-- Text document (.ttl Turtle) -->
    <xsl:output method="text"/>

    <!-- Match the root element -->
    <xsl:template match="/">

        <!-- Build the document header with all prefixes etc -->
        <!-- First the base URI and imports -->
        <xsl:value-of select="concat('# baseURI: ','http://www.assero.co.uk/MDRBCs/V1&#xa;')"/>
        <xsl:text># imports: http://www.assero.co.uk/ISO21090&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>

        <!-- Now the prefixes -->
        <xsl:text disable-output-escaping="yes">@prefix : &lt;http://www.assero.co.uk/MDRBCs/V1#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix cbc: &lt;http://www.assero.co.uk/CDISCBiomedicalConcept#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix bo: &lt;http://www.assero.co.uk/BusinessOperational#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoI: &lt;http://www.assero.co.uk/ISO11179Identification#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoR: &lt;http://www.assero.co.uk/ISO11179Registration#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoT: &lt;http://www.assero.co.uk/ISO11179Types#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrBridg: &lt;http://www.assero.co.uk/MDRBRIDG#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrIso21090: &lt;http://www.assero.co.uk/MDRISO21090#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrItems: &lt;http://www.assero.co.uk/MDRItems#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrBcts: &lt;http://www.assero.co.uk/MDRBCTs/V1#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix cCt: &lt;http://www.assero.co.uk/MDRThesaurus/CDISC/V42#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix aCt: &lt;http://www.assero.co.uk/MDRThesaurus/ACME/V1#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix owl: &lt;http://www.w3.org/2002/07/owl#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt; .&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>

        <!-- Header and imports-->
        <xsl:text disable-output-escaping="yes">&lt;http://www.assero.co.uk/MDRBCs/V1&gt;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;rdf:type owl:Ontology ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.assero.co.uk/CDISCBiomedicalConcept&gt; ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">.&#xa;</xsl:text>

        <!-- Apply to each document in the template -->
        <xsl:for-each select="/Manifest/BCFile">
            
            <!-- Extract the file name from the manifest file -->
            <xsl:variable name="Filename" select="@Name"/>
            <xsl:variable name="BCDocument" select="document($Filename)"/>
            
            <!-- Create each Research Concept Template File -->
            <xsl:apply-templates select="$BCDocument/BiomedicalConcepts/BiomedicalConcept"/>
        </xsl:for-each>
        
    </xsl:template>

    <!-- Template for the RCT -->
    <xsl:template match="BiomedicalConcept">

        <!--<xsl:variable name="BCIdentifier" select="concat(@Name,' (',@Id, ')')"/>-->
        <xsl:variable name="BCIdentifier" select="@Id"/>
        <xsl:variable name="BCItemType" select="replace(@Id,' ',$MinorSeparator)"/>
        <xsl:variable name="Org"> 
            <xsl:choose>
                <xsl:when test="@Scope='NS-ACME'">
                    <xsl:text>ACME</xsl:text>    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>CDISC</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable> 
        <xsl:variable name="Prefix" select="concat($URIPrefix,$MainSeparator,$Org,$MinorSeparator,$BCItemType)"/>
        
        <!-- Create the actual class -->
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="concat(':',$Prefix,$URIFinish)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
            <xsl:with-param name="pObjectName" select="'cbc:BiomedicalConceptInstance'" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'cbc:basedOnTemplate'" /> 
            <xsl:with-param name="pObjectName" select="concat(':',$Prefix,$MinorSeparator,'TPR')" /> 
        </xsl:call-template>
        <xsl:for-each select="Class">
            <xsl:for-each select="Attribute">
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="'cbc:hasItem'" /> 
                    <xsl:with-param name="pObjectName" select="concat(':',$Prefix,$MinorSeparator,../@Name,$MinorSeparator,@Name,$URIFinish)" /> 
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdfs:label'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,@Name,' (',@Id,')',$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        
        <xsl:choose>
            <xsl:when test="@Scope='NS-ACME'">
                <xsl:variable name="SIName" select="concat('SI',$MainSeparator,'ACME',$MinorSeparator,$BCItemType,$MainSeparator,'1')"/>
                <xsl:variable name="RSName" select="concat('RS',$MainSeparator,'ACME',$MinorSeparator,$BCItemType,$MainSeparator,'1')"/>
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="'isoI:hasIdentifier'" /> 
                    <xsl:with-param name="pObjectName" select="concat('mdrItems:',$SIName)" /> 
                </xsl:call-template>
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="'isoR:hasState'" /> 
                    <xsl:with-param name="pObjectName" select="concat('mdrItems:',$RSName)" /> 
                </xsl:call-template>
                <xsl:call-template name="CommonFields">
                    <xsl:with-param name="pDate" select="'2016-01-01'"/>
                </xsl:call-template>
                <xsl:call-template name="SubjectEnd"/>
 
                <!-- BCT Reference -->
                <xsl:call-template name="OperationalReference"> 
                    <xsl:with-param name="pCID" select="concat(':',$Prefix,$MinorSeparator,'TPR')"/>
                    <xsl:with-param name="pType" select="'BctReference'"/>
                    <xsl:with-param name="pLabel" select="'Biomedical Concept Template Reference'"/>
                    <xsl:with-param name="pRefType" select="'basedOnTemplate'"/>
                    <xsl:with-param name="pRef" select="concat('mdrBcts:',@Template)"/>
                    <xsl:with-param name="pOrdinal" select="'1'"/>
                    <xsl:with-param name="pEnabled" select="'true'"/>
                    <xsl:with-param name="pOptional" select="'false'"/>
                    <xsl:with-param name="pLocalLabel" select="''"/>
                </xsl:call-template>
                
                <!-- Scoped Identifier -->
                <xsl:call-template name="ScopedIdentifier">
                    <xsl:with-param name="pCID" select="$SIName"/>
                    <xsl:with-param name="pIdentifier" select="$BCIdentifier"/>
                    <xsl:with-param name="pVersionLabel" select="'0.1'"/>
                    <xsl:with-param name="pVersion" select="'1'"/>
                    <xsl:with-param name="pSemanticVersion" select="'1.0.0'"/>
                    <xsl:with-param name="pScope" select="@Scope"/>
                </xsl:call-template>
        
                <!-- Registration State -->
                <xsl:call-template name="RegistrationState">
                    <xsl:with-param name="pCID" select="$RSName"/>
                    <xsl:with-param name="pRA" select="'RA-123456789'"/>
                    <xsl:with-param name="pEffectiveDate" select="'2016-01-01'"/>
                    <xsl:with-param name="pUntilDate" select="'2016-01-01'"/>
                </xsl:call-template>   
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="SIName" select="concat('SI',$MainSeparator,'CDISC',$MinorSeparator,$BCItemType,$MainSeparator,'1')"/>
                <xsl:variable name="RSName" select="concat('RS',$MainSeparator,'CDISC',$MinorSeparator,$BCItemType,$MainSeparator,'1')"/>
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="'isoI:hasIdentifier'" /> 
                    <xsl:with-param name="pObjectName" select="concat('mdrItems:',$SIName)" /> 
                </xsl:call-template>
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="'isoR:hasState'" /> 
                    <xsl:with-param name="pObjectName" select="concat('mdrItems:',$RSName)" /> 
                </xsl:call-template>
                <xsl:call-template name="CommonFields">
                    <xsl:with-param name="pDate" select="'2016-01-01'"/>
                </xsl:call-template>
                <xsl:call-template name="SubjectEnd"/> 
                
                <!-- BCT Reference -->
                <xsl:call-template name="OperationalReference"> 
                    <xsl:with-param name="pCID" select="concat(':',$Prefix,$MinorSeparator,'TPR')"/>
                    <xsl:with-param name="pType" select="'BctReference'"/>
                    <xsl:with-param name="pLabel" select="'Biomedical Concept Template Reference'"/>
                    <xsl:with-param name="pRefType" select="'basedOnTemplate'"/>
                    <xsl:with-param name="pRef" select="concat('mdrBcts:',@Template)"/>
                    <xsl:with-param name="pOrdinal" select="'1'"/>
                    <xsl:with-param name="pEnabled" select="'true'"/>
                    <xsl:with-param name="pOptional" select="'false'"/>
                    <xsl:with-param name="pLocalLabel" select="''"/>
                </xsl:call-template>
                
                <!-- Scoped Identifier -->
                <xsl:call-template name="ScopedIdentifier">
                    <xsl:with-param name="pCID" select="$SIName"/>
                    <xsl:with-param name="pIdentifier" select="$BCIdentifier"/>
                    <xsl:with-param name="pVersionLabel" select="'0.1'"/>
                    <xsl:with-param name="pVersion" select="'1'"/>
                    <xsl:with-param name="pScope" select="@Scope"/>
                </xsl:call-template>
                
                <!-- Registration State -->
                <xsl:call-template name="RegistrationState">
                    <xsl:with-param name="pCID" select="$RSName"/>
                    <xsl:with-param name="pRA" select="'RA-084433759'"/>
                    <xsl:with-param name="pEffectiveDate" select="'2016-01-01'"/>
                    <xsl:with-param name="pUntilDate" select="'2016-01-01'"/>
                </xsl:call-template>  
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Build document -->
        <xsl:apply-templates select="./Class">
            <xsl:with-param name="pPrefix" select="$Prefix"/>
        </xsl:apply-templates>
        
    </xsl:template>
    
    <xsl:template match="Class">
        
        <xsl:param name="pPrefix"/>
        <xsl:variable name="BRIDGPath" select="@Name"/>
        <xsl:variable name="ACount" select="count(preceding-sibling::Class/Attribute)" />
        
        <xsl:for-each select="Attribute">
            <xsl:call-template name="Subject"> 
                <xsl:with-param name="pName" select="concat(':',$pPrefix,$MinorSeparator,../@Name,$MinorSeparator,@Name,$URIFinish)" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                <xsl:with-param name="pObjectName" select="'cbc:Item'" /> 
            </xsl:call-template>          
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'cbc:ordinal'" /> 
                <!--<xsl:with-param name="pObjectName" select="count(preceding::Attribute)+1" />--> 
                <xsl:with-param name="pObjectName" select="concat($quote,position()+$ACount,$quote,'^^xsd:positiveInteger')" /> 
            </xsl:call-template>            
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'cbc:bridg_class'" /> 
                <xsl:with-param name="pObjectName" select="concat($quote,../@Name,$quote,'^^xsd:string')" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'cbc:bridg_attribute'" /> 
                <xsl:with-param name="pObjectName" select="concat($quote,@Name,$quote,'^^xsd:string')" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'cbc:alias'" /> 
                <xsl:with-param name="pObjectName" select="concat($quote,@Alias,$quote,'^^xsd:string')" /> 
            </xsl:call-template>
            
            <xsl:variable name="ClassName" select="../@Name"/>
            <xsl:variable name="AttributeName" select="@Name"/>
            <xsl:choose>
                <xsl:when test="$BRIDGDocument/BRIDG/BRIDGClass[@Name=$ClassName]">
                    <xsl:variable name="BRIDGClass" select="$BRIDGDocument/BRIDG/BRIDGClass[@Name=$ClassName]"/>
                    <xsl:choose>
                        <xsl:when test="$BRIDGClass/BRIDGAttribute[@Name=$AttributeName]">
                            <xsl:variable name="BRIDGAttribute" select="$BRIDGClass/BRIDGAttribute[@Name=$AttributeName]"/>
                            <xsl:choose>
                                <xsl:when test="$BRIDGAttribute/@DataType='ANY'">
                                    <xsl:call-template name="X">
                                        <xsl:with-param name="pPrefix" select="$pPrefix" />
                                        <xsl:with-param name="pClassName" select="$ClassName" />
                                        <xsl:with-param name="pDatatype" select="string(./@Datatype)" />
                                        <xsl:with-param name="pBRIDGPath" select="$BRIDGPath" />
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="BRIDGDatatype">
                                        <xsl:call-template name="extractBRIDGDatatype2"> 
                                            <xsl:with-param name="pType" select="$BRIDGAttribute/@DataType" /> 
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:call-template name="X">
                                        <xsl:with-param name="pPrefix" select="$pPrefix" />
                                        <xsl:with-param name="pClassName" select="$ClassName" />
                                        <xsl:with-param name="pDatatype" select="$BRIDGDatatype" />
                                        <xsl:with-param name="pBRIDGPath" select="$BRIDGPath" />
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('&#xa;','***** Missing BRIDG Attribute ',$AttributeName,' *****','&#xa;','&#xa;')"/>
                            <xsl:call-template name="SubjectEnd"/> 
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('&#xa;','***** Missing BRIDG Class ',$ClassName,' *****','&#xa;','&#xa;')"/>
                    <xsl:call-template name="SubjectEnd"/> 
                </xsl:otherwise>
            </xsl:choose>                
        </xsl:for-each> 
    </xsl:template>

    <xsl:template match="Attribute">
        
        <xsl:param name="pPrefix" /> 
        <!--<xsl:param name="pClass" />--> 
        <xsl:param name="pDatatype" /> 
        <xsl:param name="pBRIDGPath"/>
        
        <xsl:variable name="FixedDatatype">
            <xsl:call-template name="extractBRIDGDatatype2">
                <xsl:with-param name="pType" select="$pDatatype"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="Prefix" select="concat($pPrefix,$MinorSeparator,@Name,$MinorSeparator,$pDatatype)"/>
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="concat(':',$Prefix)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
            <xsl:with-param name="pObjectName" select="'cbc:Datatype'" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'cbc:iso21090_datatype'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,$FixedDatatype,$quote,'^^xsd:string')" />
        </xsl:call-template>
        <xsl:for-each select="Property">
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="'cbc:hasProperty'" /> 
                <xsl:with-param name="pObjectName" select="concat(':',$Prefix,$MinorSeparator,./@Name,$URIFinish)" /> 
            </xsl:call-template>    
        </xsl:for-each>   
        <xsl:call-template name="SubjectEnd"/>
        <xsl:apply-templates select="./Property">
            <xsl:with-param name="pNode" select="./Property" />
            <!--<xsl:with-param name="pClass" select="$pClass" />-->
            <xsl:with-param name="pAttribute" select="@Name" />
            <xsl:with-param name="pDatatype" select="$FixedDatatype" />
            <xsl:with-param name="pPrefix" select="$Prefix" /> 
            <xsl:with-param name="pBRIDGPath" select="concat($pBRIDGPath,$PathSeparator,@Name,$PathSeparator,$pDatatype)" /> 
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="Property">
        
        <xsl:param name="pNode"/>
        <xsl:param name="Level">1</xsl:param>
        <xsl:param name="pAttribute" /> 
        <xsl:param name="pDatatype" /> 
        <xsl:param name="pPrefix" /> 
        <xsl:param name="pBRIDGPath"/>
        
        <xsl:variable name="PropertyName" select="string(@Name)"/>
        <xsl:variable name="PropertyAlias" select="string(@Alias)"/>
        <xsl:variable name="PropertyEnabled" select="string(@Enabled)"/>
        <xsl:variable name="PropertyCollect" select="string(@Collect)"/>
        <xsl:variable name="QText" select="string(@QText)"/>
        <xsl:variable name="PText" select="string(@PText)"/>
        <xsl:variable name="PropertyNode" select="."/>
        
        <xsl:variable name="PCount" select="count(preceding-sibling::Property)+1" />
        
        <xsl:variable name="Datatype" select="$DatatypeDocument/ISO21090DataTypes/ISO21090DataType[@Name=$pDatatype]"/>
        <xsl:for-each select="$Datatype/ISO21090Property">
            <xsl:choose>
                <xsl:when test="./@Name=$PropertyName">
                    <xsl:variable name="Cid" select="concat(':',$pPrefix,$MinorSeparator,@Name,$URIFinish)"/>
                    <xsl:call-template name="Subject"> 
                        <xsl:with-param name="pName" select="$Cid" /> 
                    </xsl:call-template>
                    <xsl:call-template name="PredicateObject"> 
                        <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                        <xsl:with-param name="pObjectName" select="'cbc:Property'" /> 
                    </xsl:call-template>
                    <xsl:call-template name="PredicateObject"> 
                        <xsl:with-param name="pPredicateName" select="'cbc:alias'" /> 
                        <xsl:with-param name="pObjectName" select="concat($quote,$PropertyAlias,$quote,'^^xsd:string')" /> 
                    </xsl:call-template>
                    <!--<xsl:call-template name="PredicateObject"> 
                        <xsl:with-param name="pPredicateName" select="'cbc:name'" /> 
                        <xsl:with-param name="pObjectName" select="concat($quote,$PropertyAlias,$quote,'^^xsd:string')" /> 
                    </xsl:call-template>-->
                    <xsl:variable name="PropertyDatatype" select="string(./@DataType)"/>
                    <xsl:variable name="FixedDatatype">
                        <xsl:call-template name="extractBRIDGDatatype2">
                            <xsl:with-param name="pType" select="$PropertyDatatype"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$DatatypeDocument/ISO21090DataTypes/primitiveTypes/primitiveType/@Name=$PropertyDatatype">
                            
                            <!-- Simple type -->
                            <xsl:variable name="simpleDT" select="$DatatypeDocument/ISO21090DataTypes/primitiveTypes/primitiveType[@Name=$PropertyDatatype]"/>
                            <xsl:variable name="schemaType" select="$simpleDT/@Map"/>
                            
                            <xsl:for-each select="$PropertyNode/Value">
                                <xsl:call-template name="PredicateObject"> 
                                    <xsl:with-param name="pPredicateName" select="'cbc:hasThesaurusConcept'" /> 
                                    <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,$PropertyNode/@Name,$MinorSeparator,'TR',$MinorSeparator,position(),$URIFinish)" /> 
                                </xsl:call-template>
                            </xsl:for-each>
                            
                            <!-- Ordinal -->
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:ordinal'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$PCount,$quote,'^^xsd:positiveInteger')" /> 
                            </xsl:call-template>
                            
                            <!-- Question text etc -->
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:question_text'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$QText,$quote,'^^xsd:string')" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:prompt_text'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$PText,$quote,'^^xsd:string')" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:enabled'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$PropertyEnabled,$quote,'^^xsd:boolean')" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:collect'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$PropertyCollect,$quote,'^^xsd:boolean')" /> 
                            </xsl:call-template>
                            <!-- BRIDG Path -->
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:bridg_path'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$pBRIDGPath,$PathSeparator,@Name,$quote,'^^xsd:string')"/>
                            </xsl:call-template>
                            <!-- Simple datatype -->
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:simple_datatype'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$schemaType,$quote,'^^xsd:string')"/>
                            </xsl:call-template>
                            <!-- Format -->
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:format'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$quote,'^^xsd:string')"/>
                            </xsl:call-template>
                            <!-- And finish -->
                            <xsl:call-template name="SubjectEnd"/> 
                            <!-- Values -->
                            <xsl:for-each select="$PropertyNode/Value">
                                <xsl:call-template name="TcReference" >
                                    <xsl:with-param name="pPrefix" select="concat($pPrefix,$MinorSeparator,$PropertyNode/@Name)" /> 
                                    <xsl:with-param name="pValue" select="."/>
                                    <xsl:with-param name="pOrdinal" select="position()" />
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Ordinal -->
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:ordinal'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$PCount,$quote,'^^xsd:positiveInteger')" /> 
                            </xsl:call-template>
                            
                            <!--  Complex type-->
                            <xsl:variable name="NextPrefix" select="concat($pPrefix,$MinorSeparator,$PropertyName,$MinorSeparator,$FixedDatatype)"/>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:hasComplexDatatype'" /> 
                                <xsl:with-param name="pObjectName" select="concat(':',$NextPrefix,$URIFinish)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="SubjectEnd"/> 
                        
                            <xsl:call-template name="Subject"> 
                                <xsl:with-param name="pName" select="concat(':',$NextPrefix,$URIFinish)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                                <xsl:with-param name="pObjectName" select="'cbc:Datatype'" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject">
                                <xsl:with-param name="pPredicateName" select="'cbc:iso21090_datatype'" /> 
                                <xsl:with-param name="pObjectName" select="concat($quote,$FixedDatatype,$quote,'^^xsd:string')" />
                            </xsl:call-template>
                            <xsl:for-each select="$pNode/Property">
                                <xsl:call-template name="PredicateObject">
                                    <xsl:with-param name="pPredicateName" select="'cbc:hasProperty'" /> 
                                    <xsl:with-param name="pObjectName" select="concat(':',$NextPrefix,$MinorSeparator,./@Name,$URIFinish)" /> 
                                </xsl:call-template>    
                            </xsl:for-each>   
                            <xsl:call-template name="SubjectEnd"/>
                            
                            <xsl:apply-templates select="$pNode/Property">
                                <xsl:with-param name="Level" select="$Level + 1" />
                                <xsl:with-param name="pNode" select="./Property" />
                                <!--<xsl:with-param name="pClass" select="$pClass" />-->
                                <xsl:with-param name="pAttribute" select="$pAttribute" />
                                <xsl:with-param name="pDatatype" select="$FixedDatatype" />
                                <xsl:with-param name="pPrefix" select="$NextPrefix" />
                                <xsl:with-param name="pBRIDGPath" select="concat($pBRIDGPath,$PathSeparator,$PropertyName,$PathSeparator,$FixedDatatype)"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>      
    </xsl:template>    

    <xsl:template name="TcReference">
        <xsl:param name="pPrefix" /> 
        <xsl:param name="pValue"/>
        <xsl:param name="pOrdinal"/>
        <xsl:variable name="Value">
            <xsl:choose>
                <xsl:when test="substring($pValue,1,3)='CLI'">
                    <xsl:value-of select="concat('cCt:',string($pValue))"/>
                </xsl:when>
                <xsl:when test="substring($pValue,1,3)='TH-'">
                    <xsl:value-of select="concat('aCt:',string($pValue))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($quote,string($pValue),$quote,'^^xsd:string')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="OperationalReference"> 
            <xsl:with-param name="pCID" select="concat(':',$pPrefix,$MinorSeparator,'TR',$MinorSeparator,$pOrdinal)"/>
            <xsl:with-param name="pType" select="'TcReference'"/>
            <xsl:with-param name="pLabel" select="'Thesaurus Concept Reference'"/>
            <xsl:with-param name="pRefType" select="'hasThesaurusConcept'"/>
            <xsl:with-param name="pRef" select="$Value"/>
            <xsl:with-param name="pOrdinal" select="$pOrdinal"/>
            <xsl:with-param name="pEnabled" select="'true'"/>
            <xsl:with-param name="pOptional" select="'true'"/>
            <xsl:with-param name="pLocalLabel" select="''"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="X">
        <xsl:param name="pDatatype"/>
        <xsl:param name="pPrefix"/>
        <xsl:param name="pClassName"/>
        <xsl:param name="pBRIDGPath"/>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'cbc:hasDatatype'" /> 
            <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,../@Name,$MinorSeparator,@Name,$MinorSeparator,$pDatatype)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'cbc:iso21090_datatype'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,string($pDatatype),$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/> 
        <xsl:apply-templates select=".">
            <xsl:with-param name="pPrefix" select="concat($pPrefix,$MinorSeparator,$pClassName)" />
            <xsl:with-param name="pDatatype" select="$pDatatype" />
            <xsl:with-param name="pBRIDGPath" select="$pBRIDGPath" />
        </xsl:apply-templates>
    </xsl:template>
    
</xsl:stylesheet>
