<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sr="http://www.w3.org/2005/sparql-results#"
    xmlns="http://www.cdisc.org/ns/odm/v1.3"
    exclude-result-prefixes="xs sr"
    version="1.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:key name="FormURIKey" match="sr:result" use="sr:binding[@name='form']/sr:uri"/>
    <xsl:key name="FormNameKey" match="sr:result" use="sr:binding[@name='fName']/sr:literal"/>
    
    <xsl:template match="sr:sparql">
        <xsl:variable name="uniqueFormsTemp" select="sr:results/sr:result/sr:binding[@name='form']/sr:uri"/>
        <xsl:variable name="uniqueForms" select="$uniqueFormsTemp[not(.=preceding::*)]"/>
        
        <xsl:variable name="uniqueGroupsTemp" select="sr:results/sr:result/sr:binding[@name='group']/sr:uri"/>
        <xsl:variable name="uniqueGroups" select="$uniqueGroupsTemp[not(.=preceding::*)]"/>
        
        <xsl:variable name="forms" select="sr:results/sr:result[sr:binding[@name='form']]"/>
        <xsl:variable name="groups" select="sr:results/sr:result[sr:binding[@name='group']]"/>
        <xsl:variable name="Qs" select="sr:results/sr:result[sr:binding[@name='bcProperty']]"/>
        <ODM>
            <xsl:attribute name="FileOID">
                <xsl:value-of select="'XXX'"/>
            </xsl:attribute>
            <xsl:attribute name="FileType">
                <xsl:value-of select="'Snapshot'"/>
            </xsl:attribute>
            <xsl:attribute name="Granularity">
                <xsl:value-of select="'Metadata'"/>
            </xsl:attribute>
            <xsl:attribute name="CreationDateTime">
                <xsl:value-of select="'2014-01-01T12:00:00'"/>
            </xsl:attribute>
            <Study>
                <xsl:attribute name="OID">
                    <xsl:value-of select="'aCRF Example'"/>
                </xsl:attribute>
                <GlobalVariables>
                    <StudyName><xsl:value-of select="'aCRF Example'"/></StudyName>
                    <StudyDescription><xsl:value-of select="'aCRF Example'"/></StudyDescription>
                    <ProtocolName><xsl:value-of select="'Not applicable'"/></ProtocolName>
                </GlobalVariables>
                <BasicDefinitions/>
                <MetaDataVersion>
                    <xsl:attribute name="OID">
                        <xsl:value-of select="'V001'"/>
                    </xsl:attribute>
                    <xsl:attribute name="Name">
                        <xsl:value-of select="'aCRF Metadata Example'"/>
                    </xsl:attribute>
                    <Protocol>
                        <StudyEventRef>
                            <xsl:attribute name="StudyEventOID">
                                <xsl:value-of select="'SE.001'"/>
                            </xsl:attribute>
                            <xsl:attribute name="OrderNumber">
                                <xsl:value-of select="'1'"/>
                            </xsl:attribute>
                            <xsl:attribute name="Mandatory">
                                <xsl:value-of select="'Yes'"/>
                            </xsl:attribute>
                        </StudyEventRef>    
                    </Protocol>
                    <xsl:call-template name="StudyEventDef">
                        <xsl:with-param name="pUniqueForms" select="$uniqueForms"/>
                    </xsl:call-template>
                    <xsl:call-template name="FormDefs">
                        <xsl:with-param name="pUniqueForms" select="$uniqueForms"/>
                        <xsl:with-param name="pForms" select="$forms"/>
                        <xsl:with-param name="pGroups" select="$groups"/>
                    </xsl:call-template>
                    
                    <xsl:variable name="TempfilteredGroups" select="$groups/sr:binding[@name='group']/sr:uri"/>
                    <xsl:variable name="filteredGroups" select="$TempfilteredGroups[not(.=preceding::*)]"/>
                    
                    <xsl:call-template name="ItemGroupDefs">
                        <xsl:with-param name="pUniqueGroups" select="$uniqueGroups"/>
                        <xsl:with-param name="pFilteredGroups" select="$filteredGroups"/>
                        <xsl:with-param name="pGroups" select="$groups"/>
                        <xsl:with-param name="pQs" select="$Qs"/>            
                    </xsl:call-template>
                    
                    <xsl:variable name="TempUniqueQs" select="$groups/sr:binding[@name='bcProperty']/sr:uri"/>
                    <xsl:variable name="uniqueQs" select="$TempUniqueQs[not(.=preceding::*)]"/>
                                   
                    <xsl:call-template name="ItemDefs">
                        <xsl:with-param name="pQs" select="$Qs"/>            
                        <xsl:with-param name="pUniqueQs" select="$uniqueQs"/>            
                    </xsl:call-template>
                    <xsl:call-template name="CodeLists">
                        <xsl:with-param name="pQs" select="$Qs"/>            
                        <xsl:with-param name="pUniqueQs" select="$uniqueQs"/>            
                    </xsl:call-template>
                </MetaDataVersion>
            </Study>
        </ODM>
    </xsl:template>
    
    <xsl:template name="StudyEventDef">
        <xsl:param name="pUniqueForms"/>
        <StudyEventDef>
            <xsl:attribute name="OID">
                <xsl:value-of select="'SE.001'"/>
            </xsl:attribute>
            <xsl:attribute name="Name">
                <xsl:value-of select="'???'"/>
            </xsl:attribute>
            <xsl:attribute name="Repeating">
                <xsl:value-of select="'No'"/>
            </xsl:attribute>
            <xsl:attribute name="Type">
                <xsl:value-of select="'Scheduled'"/>
            </xsl:attribute>
            <xsl:call-template name="FormRefs">
                <xsl:with-param name="pUniqueForms" select="$pUniqueForms"/>
            </xsl:call-template>
        </StudyEventDef>
    </xsl:template>
   
    <xsl:template name="FormRefs">
        <xsl:param name="pUniqueForms"/>
        <xsl:for-each select="$pUniqueForms">
            <FormRef>
                <xsl:attribute name="FormOID">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </FormRef>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="FormDefs">
        <xsl:param name="pUniqueForms"/>
        <xsl:param name="pForms"/>
        <xsl:param name="pGroups"/>
        <xsl:for-each select="$pUniqueForms">
            <FormDef>
                <xsl:variable name="form" select="."/>
                <xsl:attribute name="OID">
                    <xsl:value-of select="."/>
                </xsl:attribute>
                
                <!-- Alternative methodm, left in as an example -->
                <xsl:variable name="ParentResult" select="../../."/>
                <xsl:variable name="FormName" select="$ParentResult/sr:binding[@name='fName']/sr:literal"/>
                <xsl:attribute name="Name">
                    <xsl:value-of select="$FormName"/>
                </xsl:attribute> select=""
                <xsl:variable name="TempGroups" select="$pGroups/sr:binding[@name='group']/sr:uri[../../sr:binding[@name='form']/sr:uri/text()=$form]"/>
                <xsl:variable name="groups" select="$TempGroups[not(.=preceding::*)]"/>
                <xsl:call-template name="ItemGroupRefs">
                    <xsl:with-param name="pGroups" select="$groups"/>
                </xsl:call-template>
                
                <!-- Add domain alias -->
                <xsl:variable name="TempDomains" select="$pForms/sr:binding[@name='domain']/sr:literal[../../sr:binding[@name='form']/sr:uri/text()=$form]"/>
                <xsl:variable name="Domains" select="$TempDomains[not(.=preceding::*)]"/>
                <xsl:for-each select="$Domains">
                    <Alias>
                        <xsl:attribute name="Context">
                            <xsl:value-of select="'Domain'"/>
                        </xsl:attribute>
                        <xsl:attribute name="Name">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </Alias>    
                </xsl:for-each>
            </FormDef>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="ItemGroupRefs">
        <xsl:param name="pGroups"/>
        <xsl:for-each select="$pGroups">
            <ItemGroupRef>
                <xsl:attribute name="ItemGroupOID">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </ItemGroupRef>
        </xsl:for-each>    
    </xsl:template>

    <xsl:template name="ItemGroupDefs">
        <xsl:param name="pUniqueGroups"/>
        <xsl:param name="pFilteredGroups"/>
        <xsl:param name="pGroups"/>
        <xsl:param name="pQs"/>
        <xsl:for-each select="$pFilteredGroups">
            <xsl:variable name="group" select="."/>
            <xsl:variable name="TempQs" select="$pQs/sr:binding[@name='bcProperty']/sr:uri[../../sr:binding[@name='group']/sr:uri/text()=$group]"/>
            <xsl:variable name="Qs" select="$TempQs[not(.=preceding::*)]"/>
            <ItemGroupDef>
                <xsl:attribute name="OID">
                    <xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:variable name="TempName" select="$pGroups/sr:binding[@name='gName']/sr:literal[../../sr:binding[@name='group']/sr:uri/text()=$group]"/>
                <xsl:variable name="GroupName" select="$TempName[not(.=preceding::*)]"/>
                <xsl:attribute name="Name">
                    <xsl:value-of  select="$GroupName"/>
                </xsl:attribute>
                <xsl:call-template name="ItemRefs">
                    <xsl:with-param name="pQs" select="$Qs"/>
                </xsl:call-template>
            </ItemGroupDef>
        </xsl:for-each>    
    </xsl:template>
    
    <xsl:template name="ItemRefs">
        <xsl:param name="pQs"/>
        <xsl:for-each select="$pQs">
            <ItemRef>
                <xsl:attribute name="ItemOID">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </ItemRef>
        </xsl:for-each>    
    </xsl:template>
    
    <xsl:template name="ItemDefs">
        <xsl:param name="pQs"/>
        <xsl:param name="pUniqueQs"/>
        <xsl:for-each select="$pUniqueQs">
            <xsl:variable name="Q" select="."/>
            <!--<xsl:variable name="TempQText" select="$pQs/sr:binding[@name='alias']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            <xsl:variable name="QText" select="$TempQText[not(.=preceding::*)]"/>-->
            <xsl:variable name="QText" select="$pQs/sr:binding[@name='alias']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            
            <xsl:variable name="TempCL" select="$pQs/sr:binding[@name='cCode']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            <!--<xsl:variable name="CL" select="$TempCL[not(.=preceding::*)]"/>-->
            <xsl:variable name="CL" select="$TempCL"/>
            
            <!--<xsl:variable name="TempPresentation" select="$pQs/sr:binding[@name='datatype']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            <xsl:variable name="Presentation" select="$TempPresentation[not(.=preceding::*)]"/>-->
            <xsl:variable name="Presentation" select="$pQs/sr:binding[@name='datatype']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            
            <!--<xsl:variable name="TempSDTM" select="$pQs/sr:binding[@name='sdtmVarName']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            <xsl:variable name="SDTM" select="$TempSDTM[not(.=preceding::*)]"/>-->
            <xsl:variable name="SDTM" select="$pQs/sr:binding[@name='sdtmVarName']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            
            <!--<xsl:variable name="TempTopic" select="$pQs/sr:binding[@name='sdtmTopicName']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            <xsl:variable name="Topic" select="$TempTopic[not(.=preceding::*)]"/>-->
            <xsl:variable name="Topic" select="$pQs/sr:binding[@name='sdtmTopicName']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            
            <!-- <xsl:variable name="TempTopicValue" select="$pQs/sr:binding[@name='code']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            <xsl:variable name="TopicValue" select="$TempTopicValue[not(.=preceding::*)]"/>-->
            <xsl:variable name="TopicValue" select="$pQs/sr:binding[@name='sdtmTopicSub']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            
            <ItemDef>
                <xsl:attribute name="OID">
                    <xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:attribute name="SDSVarName">
                    <xsl:choose>
                        <xsl:when test="$SDTM">
                            <xsl:choose>
                                <xsl:when test="$Topic">
                                    <xsl:value-of select="concat($SDTM,' where ',$Topic,'=',$TopicValue)"/>                                    
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$SDTM"/>                                    
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$Presentation='integer'">
                        <xsl:variable name="Len" select="string-length($Presentation)-1"/>
                        <xsl:attribute name="DataType">
                            <xsl:value-of select="'integer'"/>
                        </xsl:attribute>
                        <xsl:attribute name="Length">
                            <xsl:value-of select="substring($Presentation,2,$Len)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$Presentation='float'">
                        <xsl:attribute name="DataType">
                            <xsl:value-of select="'float'"/>
                        </xsl:attribute>
                        <xsl:attribute name="Length">
                            <xsl:value-of select="'5'"/>
                        </xsl:attribute>
                        <xsl:attribute name="SignificantDigits">
                            <xsl:value-of select="'1'"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$Presentation='dateTime'">
                        <xsl:attribute name="DataType">
                            <xsl:value-of select="'datetime'"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$Presentation='string'">
                        <xsl:attribute name="DataType">
                            <xsl:value-of select="'text'"/>
                        </xsl:attribute>
                        <xsl:attribute name="Length">
                            <xsl:value-of select="'20'"/>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <Question>
                    <TranslatedText xml:lang="en"><xsl:value-of select="$QText"/></TranslatedText>
                </Question>
                <xsl:choose>
                    <xsl:when test="$CL">
                        <CodeListRef>
                            <xsl:attribute name="CodeListOID">
                                <xsl:value-of select="concat('CL_',.)"/>
                            </xsl:attribute>
                        </CodeListRef>
                    </xsl:when>
                </xsl:choose>
            </ItemDef>
        </xsl:for-each>    
    </xsl:template>
    
    <xsl:template name="CodeLists">
        <xsl:param name="pQs"/>
        <xsl:param name="pUniqueQs"/>
        
        <xsl:for-each select="$pUniqueQs">
            <xsl:variable name="Q" select="."/>
            <xsl:variable name="CL" select="$pQs/sr:binding[@name='cCode']/sr:literal[../../sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
            <xsl:if test="$CL">
                <CodeList>
                    <xsl:attribute name="OID">
                        <xsl:value-of select="concat('CL_',.)"/>
                    </xsl:attribute>
                    <xsl:variable name="CLIs" select="$pQs[sr:binding[@name='bcProperty']/sr:uri/text()=$Q]"/>
                    <xsl:variable name="TempCCodes" select="$CLIs/sr:binding[@name='cCode']/sr:literal"/>
                    <!--<xsl:variable name="CCodes" select="$TempCCodes[not(.=preceding::*)]"/>-->
                    <xsl:variable name="CCodes" select="$TempCCodes"/>
                    <xsl:for-each select="$CCodes">
                        <xsl:variable name="CCode" select="."/>
                        <xsl:variable name="CLI" select="$CLIs[sr:binding[@name='cCode']/sr:literal/text()=$CCode]"/>
                        <CodeListItem>
                            <xsl:attribute name="CodedValue">
                                <xsl:value-of select="$CCode"/>
                            </xsl:attribute>
                            <Decode>
                                <TranslatedText>
                                    <xsl:attribute name="xml:lang">
                                        <xsl:value-of select="'en'"/>
                                    </xsl:attribute>
                                    
                                    <xsl:variable name="X" select="$CLI/sr:binding[@name='subValue']/sr:literal"/>
                                    <!--<xsl:value-of select="$X[not(.=preceding::*)]"/>-->
                                    <xsl:value-of select="$X"/>
                                    
                                </TranslatedText>
                            </Decode>
                        </CodeListItem>
                    </xsl:for-each>
                </CodeList>
            </xsl:if>
        </xsl:for-each>    
    </xsl:template>
    
</xsl:stylesheet>