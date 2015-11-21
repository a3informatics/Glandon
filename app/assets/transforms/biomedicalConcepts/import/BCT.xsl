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
    <xsl:variable name="DotSeparator">.</xsl:variable>
    <xsl:variable name="URIPrefix">BCT</xsl:variable>
    <xsl:variable name="BCPrefix">cbc</xsl:variable>
    <xsl:variable name="BridgPrefix">mdrBridg</xsl:variable>
    <xsl:variable name="BRIDGDocument" select="document('../../bridg/import/bridg.xml')"/>
    <xsl:variable name="DatatypeDocument" select="document('../../iso21090/import/iso21090.xml')"/>
    <xsl:variable name="URIStart" select="concat($URIPrefix,$MainSeparator)"/>
    
    <!-- Remove version suffix. Namespace will have version in it. Not required. -->
    <!-- <xsl:variable name="URIFinish" select="concat($MainSeparator,'1')"/> -->
    <xsl:variable name="URIFinish" select="''"/>
    
    <!-- Text document (.ttl Turtle) -->
    <xsl:output method="text"/>
    
    <!-- Match the root element -->
    <xsl:template match="/">

        <!-- Build the document header with all prefixes etc -->
        <!-- First the base URI and imports -->
        <xsl:value-of select="concat('# baseURI: ','http://www.assero.co.uk/MDRBCTs/V1&#xa;')"/>
        <xsl:text># imports: http://www.assero.co.uk/ISO21090&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>

        <!-- Now the prefixes -->
        <xsl:text disable-output-escaping="yes">@prefix : &lt;http://www.assero.co.uk/MDRBCTs/V1#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix cbc: &lt;http://www.assero.co.uk/CDISCBiomedicalConcept#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix isoI: &lt;http://www.assero.co.uk/ISO11179Identification#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrBridg: &lt;http://www.assero.co.uk/MDRBRIDG#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrItems: &lt;http://www.assero.co.uk/MDRItems#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix mdrIso21090: &lt;http://www.assero.co.uk/MDRISO21090#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix owl: &lt;http://www.w3.org/2002/07/owl#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdf: &lt;http://www.w3.org/1999/02/22-rdf-syntax-ns#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix rdfs: &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema#&gt; .&#xa;</xsl:text>
        <xsl:text>&#xa;</xsl:text>

        <!-- Header and imports-->
        <xsl:text disable-output-escaping="yes">&lt;http://www.assero.co.uk/MDRBCTs/V1&gt;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;rdf:type owl:Ontology ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">&#009;owl:imports &lt;http://www.assero.co.uk/CDISCBiomedicalConcept&gt; ;&#xa;</xsl:text>
        <xsl:text disable-output-escaping="yes">.&#xa;</xsl:text>

        <!-- Create each Research Concept Template -->
        <xsl:apply-templates select="BiomedicalConceptTemplates/BiomedicalConceptTemplate"/>
        
    </xsl:template>

    <!-- Template for the RCT -->
    <xsl:template match="BiomedicalConceptTemplate">

        <xsl:variable name="BCTItemType" select="replace(@Id,' ','_')"/>
        <xsl:variable name="Prefix" select="concat($URIStart,$BCTItemType)"/>
        
        <!-- Create the actual class -->
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="concat(':',$Prefix,$URIFinish)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
            <xsl:with-param name="pObjectName" select="concat($BCPrefix,':BiomedicalConceptTemplate')" /> 
        </xsl:call-template>
        <xsl:for-each select="Class">
            <xsl:for-each select="Attribute">
                <xsl:call-template name="PredicateObject"> 
                    <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasItem')" /> 
                    <xsl:with-param name="pObjectName" select="concat(':',$Prefix,$MinorSeparator,@Name,$URIFinish)" /> 
                </xsl:call-template>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdfs:label'" /> 
            <xsl:with-param name="pObjectName" select="concat($quote,@Name,$quote,'^^xsd:string')" /> 
        </xsl:call-template>
        <xsl:variable name="SIName" select="concat('SI',$MainSeparator,$BCTItemType,$URIFinish)"/>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'isoI:hasIdentifier'" /> 
            <xsl:with-param name="pObjectName" select="concat('mdrItems:',$SIName)" /> 
        </xsl:call-template>
        <xsl:call-template name="SubjectEnd"/> 
        
        <!-- Scoped Identifier -->
        <xsl:call-template name="ScopedIdentifier">
            <xsl:with-param name="pCID" select="$SIName"/>
            <xsl:with-param name="pIdentifier" select="'PQR BC Template'"/>
            <xsl:with-param name="pVersionLabel" select="'0.1'"/>
            <xsl:with-param name="pVersion" select="'1'"/>
            <xsl:with-param name="pScope" select="'NS-CDISC'"/>
        </xsl:call-template>

        <!-- Build document -->
        <xsl:apply-templates select="./Class">
            <xsl:with-param name="pPrefix" select="$Prefix"/>
        </xsl:apply-templates>
        
    </xsl:template>
    
    <xsl:template match="Class">
        
        <xsl:param name="pPrefix"/>
        
        <xsl:for-each select="Attribute">
            <xsl:call-template name="Subject"> 
                <xsl:with-param name="pName" select="concat(':',$pPrefix,$MinorSeparator,@Name,$URIFinish)" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                <xsl:with-param name="pObjectName" select="concat($BCPrefix,':Item')" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':isItemOf')" /> 
                <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$URIFinish)" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasClassRef')" /> 
                <xsl:with-param name="pObjectName" select="concat($BridgPrefix,':',../@Name)" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasAttributeRef')" /> 
                <xsl:with-param name="pObjectName" select="concat($BridgPrefix,':',../@Name,$MinorSeparator,@Name)" /> 
            </xsl:call-template>
            <xsl:call-template name="PredicateObject"> 
                <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':alias')" /> 
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
                                    <xsl:call-template name="PredicateObject"> 
                                        <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasDatatype')" /> 
                                        <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,../@Name,$MinorSeparator,@Name,$MinorSeparator,@Datatype,$URIFinish)" /> 
                                    </xsl:call-template>
                                    <xsl:call-template name="SubjectEnd"/> 
                                    <xsl:apply-templates select=".">
                                        <xsl:with-param name="pClass" select="$ClassName" />
                                        <xsl:with-param name="pDatatype" select="@Datatype" />
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:variable name="BRIDGDatatype">
                                        <xsl:call-template name="extractBRIDGDatatype2"> 
                                            <xsl:with-param name="pType" select="$BRIDGAttribute/@DataType" /> 
                                        </xsl:call-template>
                                    </xsl:variable>
                                    <xsl:call-template name="PredicateObject"> 
                                        <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasDatatype')" /> 
                                        <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,../@Name,$MinorSeparator,@Name,$MinorSeparator,$BRIDGDatatype,$URIFinish)" /> 
                                    </xsl:call-template>
                                    <xsl:call-template name="SubjectEnd"/> 
                                    <xsl:apply-templates select=".">
                                        <xsl:with-param name="pPrefix" select="concat($pPrefix,$MinorSeparator)" />
                                        <xsl:with-param name="pClass" select="$ClassName" />
                                        <xsl:with-param name="pDatatype" select="$BRIDGDatatype" />
                                        <xsl:with-param name="pRawDatatype" select="$BRIDGAttribute/@DataType" />
                                    </xsl:apply-templates>
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
        
        <xsl:param name="pPrefix"/>
        <xsl:param name="pClass" /> 
        <xsl:param name="pDatatype" /> 
        <xsl:param name="pRawDatatype" /> 
        
        <xsl:variable name="Prefix" select="concat($pPrefix,$pClass,$MinorSeparator,@Name,$MinorSeparator,$pDatatype)"/>
        <xsl:call-template name="Subject"> 
            <xsl:with-param name="pName" select="concat(':',$Prefix,$URIFinish)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
            <xsl:with-param name="pObjectName" select="concat($BCPrefix,':Datatype')" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':isDatatypeOf')" /> 
            <xsl:with-param name="pObjectName" select="concat(':',$URIStart,$pClass,$MinorSeparator,@Name,$URIFinish)" /> 
        </xsl:call-template>
        <xsl:call-template name="PredicateObject"> 
            <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasDatatypeRef')" /> 
            <xsl:with-param name="pObjectName" select="concat('mdrIso21090:DT-',$pDatatype)" /> 
        </xsl:call-template>
        <xsl:for-each select="Property">
            <xsl:call-template name="PredicateObject">
                <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasProperty')" /> 
                <xsl:with-param name="pObjectName" select="concat(':',$Prefix,$MinorSeparator,./@Name,$URIFinish)" /> 
            </xsl:call-template>    
        </xsl:for-each>   
        <xsl:call-template name="SubjectEnd"/>
        <xsl:apply-templates select="./Property">
            <xsl:with-param name="pNode" select="./Property" />
            <xsl:with-param name="pClass" select="$pClass" />
            <xsl:with-param name="pAttribute" select="@Name" />
            <xsl:with-param name="pDatatype" select="$pDatatype" />
            <xsl:with-param name="pRawDatatype" select="$pRawDatatype" />
            <xsl:with-param name="pPrefix" select="$Prefix" /> 
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="Property">
        
        <xsl:param name="pNode"/>
        <xsl:param name="Level">1</xsl:param>
        <xsl:param name="pClass" /> 
        <xsl:param name="pAttribute" /> 
        <xsl:param name="pDatatype" /> 
        <xsl:param name="pRawDatatype" /> 
        <xsl:param name="pPrefix" /> 
        
        <xsl:variable name="PropertyName" select="string(@Name)"/>
        <xsl:variable name="PropertyAlias" select="string(@Alias)"/>
        
        <xsl:variable name="Datatype" select="$DatatypeDocument/ISO21090DataTypes/ISO21090DataType[@Name=$pDatatype]"/>
        <xsl:for-each select="$Datatype/ISO21090Property">
            
            <xsl:choose>
                <xsl:when test="./@Name=$PropertyName">
                    <xsl:call-template name="Subject"> 
                        <xsl:with-param name="pName" select="concat(':',$pPrefix,$MinorSeparator,@Name,$URIFinish)" /> 
                    </xsl:call-template>
                    <xsl:call-template name="PredicateObject"> 
                        <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                        <xsl:with-param name="pObjectName" select="concat($BCPrefix,':Property')" /> 
                    </xsl:call-template>
                    <xsl:call-template name="PredicateObject"> 
                        <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':isPropertyOf')" /> 
                        <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$URIFinish)" /> 
                    </xsl:call-template>
                    <xsl:call-template name="PredicateObject"> 
                        <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':alias')" /> 
                        <xsl:with-param name="pObjectName" select="concat($quote,$PropertyAlias,$quote,'^^xsd:string')" /> 
                    </xsl:call-template>
                    <xsl:variable name="PropertyDatatype" select="string(./@DataType)"/>
                    <xsl:choose>
                        <xsl:when test="$DatatypeDocument/ISO21090DataTypes/primitiveTypes/primitiveType/@Name=$PropertyDatatype">
                            <!-- Simple type -->
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasSimpleDatatype')" /> 
                                <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,@Name,$MinorSeparator,'Value',$URIFinish)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="SubjectEnd"/> 
                            
                            <xsl:call-template name="Subject"> 
                                <xsl:with-param name="pName" select="concat(':',$pPrefix,$MinorSeparator,@Name,$MinorSeparator,'Value',$URIFinish)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                                <xsl:with-param name="pObjectName" select="concat($BCPrefix,':PropertyValue')" /> 
                            </xsl:call-template>
                            <xsl:call-template name="SubjectEnd"/> 
                        </xsl:when>
                        <xsl:otherwise>
                            <!--  Complex type-->
                            <xsl:variable name="NextPrefix" select="concat($pPrefix,$MinorSeparator,$PropertyName,$MinorSeparator,$PropertyDatatype)"/>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasComplexDatatype')" /> 
                                <xsl:with-param name="pObjectName" select="concat(':',$NextPrefix,$URIFinish)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="SubjectEnd"/> 
                        
                            <xsl:call-template name="Subject"> 
                                <xsl:with-param name="pName" select="concat(':',$NextPrefix,$URIFinish)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="'rdf:type'" /> 
                                <xsl:with-param name="pObjectName" select="concat($BCPrefix,':Datatype')" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':isDatatypeOf')" /> 
                                <xsl:with-param name="pObjectName" select="concat(':',$pPrefix,$MinorSeparator,$PropertyName,$URIFinish)" /> 
                            </xsl:call-template>
                            <xsl:call-template name="PredicateObject"> 
                                <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasDatatypeRef')" /> 
                                <xsl:with-param name="pObjectName" select="concat('mdrIso21090:DT-',$pDatatype)" /> 
                            </xsl:call-template>
                            <xsl:for-each select="$pNode/Property">
                                <xsl:call-template name="PredicateObject">
                                    <xsl:with-param name="pPredicateName" select="concat($BCPrefix,':hasProperty')" /> 
                                    <xsl:with-param name="pObjectName" select="concat(':',$NextPrefix,$MinorSeparator,./@Name,$URIFinish)" /> 
                                </xsl:call-template>    
                            </xsl:for-each>   
                            <xsl:call-template name="SubjectEnd"/>
                            
                            <xsl:apply-templates select="$pNode/Property">
                                <xsl:with-param name="Level" select="$Level + 1" />
                                <xsl:with-param name="pNode" select="./Property" />
                                <xsl:with-param name="pClass" select="$pClass" />
                                <xsl:with-param name="pAttribute" select="$pAttribute" />
                                <xsl:with-param name="pDatatype" select="$PropertyDatatype" />
                                <xsl:with-param name="pRawDatatype" select="$PropertyDatatype" />
                                <xsl:with-param name="pPrefix" select="$NextPrefix" /> 
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>      
    </xsl:template>    

</xsl:stylesheet>
