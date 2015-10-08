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
    <xsl:variable name="MainSeparator">-</xsl:variable>
    <xsl:variable name="MinorSeparator">_</xsl:variable>
    <xsl:variable name="BRIDGDocument" select="document('../../bridg/import/bridg.xml')"/>
    <xsl:variable name="DatatypeDocument" select="document('../../iso21090/import/iso21090.xml')"/>
    
    <!-- Text document (.ttl Turtle) -->
    <xsl:output method="text"/>

    <!-- Match the root element -->
    <xsl:template match="/">

        <!-- Build the document header with all prefixes etc -->
        <!-- First the base URI and imports -->
        <xsl:value-of select="concat('# baseURI: ','http://www.assero.co.uk/MDRCDISCBC&#xa;')"/>
        <xsl:text># imports: http://www.assero.co.uk/ISO21090&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>

        <!-- Now the prefixes -->
        <xsl:text disable-output-escaping="yes">@prefix : &lt;http://www.assero.co.uk/MDRCDISCBC#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix cbc: &lt;http://www.assero.co.uk/CDISCBiomedicalConcept#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrBridg: &lt;http://www.assero.co.uk/MDRBRIDG#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrIso21090: &lt;http://www.assero.co.uk/MDRISO21090#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoI: &lt;http://www.assero.co.uk/ISO11179Identification#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix item: &lt;http://www.assero.co.uk/MDRItems#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix owl: &lt;http://www.w3.org/2002/07/owl#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt; .&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>

        <!-- Header and imports-->
        <xsl:text disable-output-escaping="yes">&lt;http://www.assero.co.uk/MDRCDISCBC&gt;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;rdf:type owl:Ontology ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.assero.co.uk/CDISCBiomedicalConcept&gt; ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">.&#xa;</xsl:text>

        <!-- Create each Research Concept Template -->
        <xsl:apply-templates select="ResearchConcepts/ResearchConcept"/>
        
    </xsl:template>

    <!-- Template for the RCT -->
    <xsl:template match="ResearchConcept">

        <!-- Create the actual class -->
        <xsl:variable name="Prefix" select="concat('BC',$MainSeparator,@Id)"/>
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="concat(':',$Prefix)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
            <xsl:with-param name="pObjectName" select="'cbc:BiomedicalConceptInstance'" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'cbc:name'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,@Name,$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:for-each select="Class">
            <xsl:for-each select="Attribute">
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="'cbc:hasItemRelationship'" /> 
                    <xsl:with-param name="pObjectName" select="concat(':',$Prefix,$MinorSeparator,../@Name,$MinorSeparator,@Name)" /> 
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdfs:label'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,@Name,' Biomedical Concept',$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:variable name="SIName" select="concat('SI',$MainSeparator,'CDISC_BC_',@Id,$MainSeparator,'1')"/>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoI:identifierRelationship'" /> 
            <xsl:with-param name="pObjectName" select="concat('item:',$SIName)" /> 
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/> 
        
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="concat('item:',$SIName)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
            <xsl:with-param name="pObjectName" select="'isoI:ScopedIdentifier'" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoI:identifier'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,@Id,$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoI:version'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,'1',$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoI:scopeRelationship'" /> 
            <xsl:with-param name="pObjectName" select="concat('item:','NS-CDISC')" /> 
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/> 
        
        <xsl:apply-templates select="./Class"/>
        
    </xsl:template>
    
    <xsl:template match="Class">
        
        <xsl:variable name="Prefix" select="concat('BC',$MainSeparator,../@Id)"/>
        <xsl:for-each select="Attribute">
            <xsl:call-template name="Subject"> 
                <xsl:with-param name="pName" select="concat(':',$Prefix,$MinorSeparator,../@Name,$MinorSeparator,@Name)" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                <xsl:with-param name="pObjectName" select="'cbc:BCItem'" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'cbc:isItemOfRelationship'" /> 
                <xsl:with-param name="pObjectName" select="concat(':',$Prefix)" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'cbc:hasClassRefRelationship'" /> 
                <xsl:with-param name="pObjectName" select="concat('mdrBridg',':',../@Name)" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'cbc:hasAttributeRefRelationship'" /> 
                <xsl:with-param name="pObjectName" select="concat('mdrBridg',':',../@Name,$MinorSeparator,@Name)" /> 
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
                                        <xsl:with-param name="pPrefix" select="$Prefix" />
                                        <xsl:with-param name="pClassName" select="$ClassName" />
                                        <xsl:with-param name="pDatatype" select="string(./@Datatype)" />
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="BRIDGDatatype">
                                        <xsl:call-template name="extractBRIDGDatatype2"> 
                                            <xsl:with-param name="pType" select="$BRIDGAttribute/@DataType" /> 
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:call-template name="X">
                                        <xsl:with-param name="pPrefix" select="$Prefix" />
                                        <xsl:with-param name="pClassName" select="$ClassName" />
                                        <xsl:with-param name="pDatatype" select="$BRIDGDatatype" />
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
            <xsl:with-param name="pPredicateName" select="'cbc:hasDatatypeRefRelationship'" /> 
            <xsl:with-param name="pObjectName" select="concat('mdrIso21090:DT-',$FixedDatatype)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'cbc:isDatatypeOfRelationship'" /> 
            <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,@Name)" /> 
        </xsl:call-template>
        <xsl:for-each select="Property">
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="'cbc:hasPropertyRelationship'" /> 
                <xsl:with-param name="pObjectName" select="concat(':',$Prefix,$MinorSeparator,./@Name)" /> 
            </xsl:call-template>    
        </xsl:for-each>   
        <xsl:call-template name="SubjectEnd"/>
        <xsl:apply-templates select="./Property">
            <xsl:with-param name="pNode" select="./Property" />
            <!--<xsl:with-param name="pClass" select="$pClass" />-->
            <xsl:with-param name="pAttribute" select="@Name" />
            <xsl:with-param name="pDatatype" select="$FixedDatatype" />
            <xsl:with-param name="pPrefix" select="$Prefix" /> 
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="Property">
        
        <xsl:param name="pNode"/>
        <xsl:param name="Level">1</xsl:param>
        <xsl:param name="pAttribute" /> 
        <xsl:param name="pDatatype" /> 
        <xsl:param name="pPrefix" /> 
        
        <xsl:variable name="PropertyName" select="string(@Name)"/>
        <xsl:variable name="PropertyAlias" select="string(@Alias)"/>
        <xsl:variable name="PropertyNode" select="."/>
        
        <xsl:variable name="Datatype" select="$DatatypeDocument/ISO21090DataTypes/ISO21090DataType[@Name=$pDatatype]"/>
        <xsl:for-each select="$Datatype/ISO21090Property">
            
            <xsl:choose>
                <xsl:when test="./@Name=$PropertyName">
                    <xsl:call-template name="Subject"> 
                        <xsl:with-param name="pName" select="concat(':',$pPrefix,$MinorSeparator,@Name)" /> 
                    </xsl:call-template>
                    <xsl:call-template name="PredicateObject"> 
                        <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                        <xsl:with-param name="pObjectName" select="'cbc:Property'" /> 
                    </xsl:call-template>
                    <xsl:call-template name="PredicateObject"> 
                        <xsl:with-param name="pPredicateName" select="'cbc:isPropertyOfRelationship'" /> 
                        <xsl:with-param name="pObjectName" select="concat(':',$pPrefix)" /> 
                    </xsl:call-template>
                    <xsl:call-template name="PredicateObject"> 
                        <xsl:with-param name="pPredicateName" select="'cbc:alias'" /> 
                        <xsl:with-param name="pObjectName" select="concat($quote,$PropertyAlias,$quote,'^^xsd:string')" /> 
                    </xsl:call-template>
                    <xsl:variable name="PropertyDatatype" select="string(./@DataType)"/>
                    <xsl:variable name="FixedDatatype">
                        <xsl:call-template name="extractBRIDGDatatype2">
                            <xsl:with-param name="pType" select="$PropertyDatatype"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$DatatypeDocument/ISO21090DataTypes/primitiveTypes/primitiveType/@Name=$PropertyDatatype">
                            <!-- Simple type -->
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:hasSimpleDatatypeRelationship'" /> 
                                <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,@Name,$MinorSeparator,'Value1')" /> 
                            </xsl:call-template>
                            <xsl:call-template name="SubjectEnd"/> 
                            
                            <xsl:call-template name="Value" >
                                <xsl:with-param name="pPrefix" select="concat($pPrefix,$MinorSeparator,@Name)" /> 
                                <xsl:with-param name="pValue" select="$PropertyNode/*[1]"/>
                                <xsl:with-param name="pLevel" select="1" />
                            </xsl:call-template>
                            
                        </xsl:when>
                        <xsl:otherwise>
                            <!--  Complex type-->
                            <xsl:variable name="NextPrefix" select="concat($pPrefix,$MinorSeparator,$PropertyName,$MinorSeparator,$FixedDatatype)"/>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:hasComplexDatatypeRelationship'" /> 
                                <xsl:with-param name="pObjectName" select="concat(':',$NextPrefix)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="SubjectEnd"/> 
                        
                            <xsl:call-template name="Subject"> 
                                <xsl:with-param name="pName" select="concat(':',$NextPrefix)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                                <xsl:with-param name="pObjectName" select="'cbc:Datatype'" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:hasDatatypeRefRelationship'" /> 
                                <xsl:with-param name="pObjectName" select="concat('mdrIso21090:DT-',$FixedDatatype)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'cbc:isDatatypeOfRelationship'" /> 
                                <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,$PropertyName)" /> 
                            </xsl:call-template>
                            <xsl:for-each select="$pNode/Property">
                                <xsl:call-template name="PredicateObject">
                                    <xsl:with-param name="pPredicateName" select="'cbc:hasPropertyRelationship'" /> 
                                    <xsl:with-param name="pObjectName" select="concat(':',$NextPrefix,$MinorSeparator,./@Name)" /> 
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
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>      
    </xsl:template>    

    <xsl:template name="Value">
        
        <xsl:param name="pPrefix" /> 
        <xsl:param name="pValue"/>
        <xsl:param name="pLevel"/>
        
        <xsl:variable name="pNextLevel" select="($pLevel + 1)"/>
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="concat(':',$pPrefix,$MinorSeparator,'Value',$pLevel)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
            <xsl:with-param name="pObjectName" select="'cbc:PropertyValue'" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'cbc:value'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,string($pValue),$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="$pValue/following-sibling::Value[1]">
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="'cbc:nextValueRelationship'" /> 
                    <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,'Value',$pNextLevel)" /> 
                </xsl:call-template>
                <xsl:call-template name="SubjectEnd"/> 
                <xsl:call-template name="Value" >
                    <xsl:with-param name="pPrefix" select="$pPrefix" /> 
                    <xsl:with-param name="pValue" select="$pValue/following-sibling::Value[1]"/>
                    <xsl:with-param name="pLevel" select="$pNextLevel"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="SubjectEnd"/> 
            </xsl:otherwise>
        </xsl:choose>
               
    </xsl:template>
    
    <xsl:template name="X">
        
        <xsl:param name="pDatatype"/>
        <xsl:param name="pPrefix"/>
        <xsl:param name="pClassName"/>
        
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'cbc:hasDatatypeRelationship'" /> 
            <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,../@Name,$MinorSeparator,@Name,$MinorSeparator,$pDatatype)" /> 
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/> 
        <xsl:apply-templates select=".">
            <xsl:with-param name="pPrefix" select="concat($pPrefix,$MinorSeparator,$pClassName)" />
            <xsl:with-param name="pDatatype" select="$pDatatype" />
        </xsl:apply-templates>
        
    </xsl:template>
    
</xsl:stylesheet>
