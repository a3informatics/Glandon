<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="Property">
        <xsl:copy>
            <xsl:attribute name="QText">Question text</xsl:attribute>
            <xsl:attribute name="PText">Prompt text</xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!--<xsl:template match="Class">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:if test="@Name='PerformedObservation'">
                <Attribute Alias="Laterality" Name="targetAnatomicSiteLateralityCode">
                    <Property Enabled="true" Collect="false" Alias="Laterality (LAT)" Name="code"/>
                </Attribute>
            </xsl:if>
        </xsl:copy>   
    </xsl:template>-->

    <!--<xsl:template match="Attribute[@Alias='DateTime']/Property/Property">
        <xsl:copy>
            <xsl:attribute name="Alias">Date and Time (xxDTC)</xsl:attribute>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
-->


</xsl:stylesheet>
