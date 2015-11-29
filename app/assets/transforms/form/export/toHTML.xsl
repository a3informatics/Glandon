<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3c.org/1999/xlink" exclude-result-prefixes="odm xlink">

	<!--<xsl:output method="html" version="4.0" encoding="UTF-8" indent="no"/>-->

	<!--
		Template: The main template.
		Purpose:  Builds the entire HTML page.
	-->
	<xsl:template match="/">

		<!-- Create the HTML Header, include any style information we need -->
		<html>
			<head/>
			<body>
				<xsl:apply-templates select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:FormDef"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="odm:FormDef">
		<table class="table table-striped table-bordered table-condensed">
			<tr>
				<td colspan="2"><h4><xsl:value-of select="@Name"/></h4></td>
				<td>
					<h4>
						<xsl:variable name="Aliases" select="./odm:Alias"/>
						<xsl:for-each select="$Aliases">
							<xsl:value-of select="concat('Domain: ',./@Name)"/><br/>
						</xsl:for-each>
					</h4>
				</td>
			</tr>
		<xsl:apply-templates select="./odm:ItemGroupRef"/>
		</table>		
	</xsl:template>

	<xsl:template match="odm:ItemGroupRef">
		<xsl:variable name="OID" select="@ItemGroupOID"/>
		<xsl:variable name="IGDef"
			select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$OID]"/>
		<xsl:apply-templates select="$IGDef"/>
	</xsl:template>

	<xsl:template match="odm:ItemGroupDef">
		<xsl:if test="./odm:ItemRef">
			<!--<table class="table table-striped table-bordered table-condensed">-->
				<tr>
					<td colspan="3"><h5><xsl:value-of select="@Name"/></h5></td>
					<!--<td align="right" width="25%">
						<p>
							<font color="red">
								<xsl:value-of select="./Alias[@Context='GroupAnnotation']/@Name"/>
							</font>
						</p>
					</td>
					<td align="right" width="25%">
						<xsl:variable name="Loinc" select="./Alias[@Context='LOINC']/@Name"/>
						<xsl:if test="$Loinc">
							<p>
								<font color="green">
									LOINC=<xsl:value-of select="$Loinc"/>
								</font>
							</p>	
						</xsl:if>
					</td>-->
				</tr>
			<!--</table><br/>
			<table class="table table-striped table-bordered table-condensed">-->
				<xsl:apply-templates select="./odm:ItemRef"/>
			<!--</table><br/>-->	
		</xsl:if>
	</xsl:template>

	<xsl:template match="odm:ItemRef">
		<xsl:variable name="OID" select="@ItemOID"/>
		<xsl:apply-templates select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$OID]"/>
	</xsl:template>

	<xsl:template match="odm:ItemDef">
		<tr>
			<td>
				<p>
					<xsl:call-template name="QuestionText">
						<xsl:with-param name="OID" select="@OID"/>
					</xsl:call-template><br/>
					<font color="red">
						<xsl:call-template name="SDTMAnnotation"/>
					</font>
				</p>
			</td>
			<td colspan="2">
				<p>
					<xsl:call-template name="DataField"/>
				</p>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="odm:Alias">
		<xsl:choose>
			<xsl:when test="@Context = 'DomainAnnotation'">-->
				<xsl:value-of select="concat('Domain ',@Name)"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!--
		Template: QuestionText
		Purpose:  Displays the question text for a given Item.
	-->
	<xsl:template name="QuestionText">
		<xsl:choose>
			<xsl:when test="./odm:Question">
				<xsl:value-of select="./odm:Question/odm:TranslatedText"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@Name"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		Template: SDTMAnnotation
		Purpose:  Determines if SDSVarName attribute exists and sets the annotated variable appropriately.
	-->
	<xsl:template name="SDTMAnnotation">
		<xsl:choose>
			<xsl:when test="./@SDSVarName">
				<xsl:value-of select="@SDSVarName"/>
			</xsl:when>
			<xsl:otherwise>
				<b>@SDSVarName Not Set</b>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		Template: DataField
		Purpose:  Constructs a data field for an Item depending on the ItemDef
	-->
	<xsl:template name="DataField">
		<xsl:variable name="ID_DT" select="@DataType"/>
		<xsl:choose>

			<!-- CodeList -->
			<xsl:when test="./odm:CodeListRef">
				<xsl:variable name="OID" select="./odm:CodeListRef/@CodeListOID"/>
				<xsl:apply-templates select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$OID]"/>
			</xsl:when>

			<!-- Simple Text Field -->
			<xsl:when test="$ID_DT='text'">
				<xsl:choose>
					<xsl:when test="./@Length">
						<xsl:choose>
							<xsl:when test="@Length > 100">
								<textarea>
									<xsl:attribute name="name">
										<xsl:value-of select="@OID"/>
									</xsl:attribute>
									<xsl:attribute name="rows"> 5 </xsl:attribute>
									<xsl:attribute name="cols"> 40 </xsl:attribute>
								</textarea>
							</xsl:when>
							<xsl:otherwise>
								<input>
									<xsl:attribute name="type">text</xsl:attribute>
									<xsl:attribute name="name">
										<xsl:value-of select="@OID"/>
									</xsl:attribute>
									<xsl:choose>
										<xsl:when test="@Length > 50">
											<xsl:attribute name="size">50</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="size">
												<xsl:value-of select="@Length"/>
											</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="maxlength">
										<xsl:value-of select="@Length"/>
									</xsl:attribute>
								</input>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<i>Missing length attribute</i>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- Integer field -->
			<xsl:when test="$ID_DT='integer'">
				<input>
					<xsl:attribute name="type"> text </xsl:attribute>
					<xsl:attribute name="name">
						<xsl:value-of select="@OID"/>
					</xsl:attribute>
					<xsl:attribute name="size">
						<xsl:value-of select="@Length"/>
					</xsl:attribute>
					<xsl:attribute name="maxlength">
						<xsl:value-of select="@Length"/>
					</xsl:attribute>
				</input>

			</xsl:when>

			<!-- Float field -->
			<xsl:when test="$ID_DT='float'">
				<input>
					<xsl:attribute name="type"> text </xsl:attribute>
					<xsl:attribute name="name">
						<xsl:value-of select="@OID"/>A </xsl:attribute>
					<xsl:attribute name="size">
						<xsl:value-of select="@Length"/>
					</xsl:attribute>
					<xsl:attribute name="maxlength">
						<xsl:value-of select="@Length"/>
					</xsl:attribute>
				</input> . <input>
					<xsl:attribute name="type"> text </xsl:attribute>
					<xsl:attribute name="name">
						<xsl:value-of select="@OID"/>B </xsl:attribute>
					<xsl:attribute name="size">
						<xsl:value-of select="@SignificantDigits"/>
					</xsl:attribute>
					<xsl:attribute name="maxlength">
						<xsl:value-of select="@SignificantDigits"/>
					</xsl:attribute>
				</input>
			</xsl:when>

			<!-- Date field -->
			<xsl:when test="$ID_DT='date'">
				<xsl:call-template name="date"/>
			</xsl:when>

			<!-- Time field -->
			<xsl:when test="$ID_DT='time'">
				<xsl:call-template name="Time"/>
			</xsl:when>

			<!-- DateTime field -->
			<xsl:when test="$ID_DT='datetime'">
				<xsl:call-template name="date"/>
				<b> + </b>
				<xsl:call-template name="Time"/>
			</xsl:when>

			<!-- Something we do not handle yet -->
			<xsl:otherwise>
				<i>Not represented yet</i>
			</xsl:otherwise>
		</xsl:choose>

		<!-- If MeasurementUnitRef present, add the units -->
		<xsl:if test="./odm:MeasurementUnitRef[@MeasurementUnitOID]">
			<xsl:for-each select="./odm:MeasurementUnitRef">
				<!--
			 		The for-each is not strictly required, but processor fails to set $ID_MUOID
			 		<xsl:variable name="ID_MUOID" select="./odm:MeasurementUnitRef[@MeasurementUnitOID]"/>
			 	-->
				<xsl:variable name="ID_MUOID" select="@MeasurementUnitOID"/>
				<xsl:for-each select="/odm:ODM/odm:Study/odm:BasicDefinitions/odm:MeasurementUnit">
					<xsl:if test="@OID=$ID_MUOID"> ( <xsl:value-of
							select="./odm:Symbol/odm:TranslatedText"/> ) </xsl:if>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:if>

	</xsl:template>

	<xsl:template match="odm:CodeList">
	
		<p>
			<xsl:apply-templates select="./odm:CodeListItem"/>
		</p>
	
	</xsl:template>
	
	<xsl:template match="odm:CodeListItem">
		
		<!-- Remove the odm: prefix for PHP environment, needed for Oxygen-->
		<!--<xsl:variable name="Alias" select="./odm:Alias[@Context='UCUM']"/>-->
		<xsl:variable name="Alias" select="./Alias[@Context='UCUM']"/>
		<table width="100%">
			<tr>
				<td width="50%">
					<p>
						<input type="radio">
							<xsl:attribute name="name">
								<xsl:value-of select="../@OID"/>
							</xsl:attribute>
							<xsl:attribute name="value">
								<xsl:value-of select="@CodedValue"/>
							</xsl:attribute>
						</input>
						<xsl:value-of select="./odm:Decode/odm:TranslatedText"/>
					</p>
				</td>
				<td width="50%">
					<xsl:if test="$Alias/@Name">
						<p>
							<font color="green">
								UCUM=<xsl:value-of select="$Alias/@Name"/>
							</font>
						</p>	
					</xsl:if>
				</td>
			</tr>
		</table>
		
	</xsl:template>
	
	<!--
		Template: Date
		Purpose:  Builds a date control.
	-->
	<xsl:template name="date">
		<xsl:call-template name="day"/>
		<xsl:call-template name="month"/>
		<xsl:call-template name="year"/>
	</xsl:template>

	<!--
		Template: Time
		Purpose:  Builds a time control.
	-->
	<xsl:template name="Time">
		<xsl:call-template name="Hour"/>
		<b>:</b>
		<xsl:call-template name="Minute"/>
	</xsl:template>

	<!--
		Template: Day
		Purpose:  Builds a HTML select control for days as part of a date control
	-->
	<xsl:template name="day">
		<select>
			<xsl:attribute name="name"> XXX </xsl:attribute>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="1"/>
				<xsl:with-param name="optiontext" select="1"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="2"/>
				<xsl:with-param name="optiontext" select="2"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="3"/>
				<xsl:with-param name="optiontext" select="3"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="4"/>
				<xsl:with-param name="optiontext" select="4"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="5"/>
				<xsl:with-param name="optiontext" select="5"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="6"/>
				<xsl:with-param name="optiontext" select="6"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="7"/>
				<xsl:with-param name="optiontext" select="7"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="8"/>
				<xsl:with-param name="optiontext" select="8"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="9"/>
				<xsl:with-param name="optiontext" select="9"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="10"/>
				<xsl:with-param name="optiontext" select="10"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="11"/>
				<xsl:with-param name="optiontext" select="11"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="12"/>
				<xsl:with-param name="optiontext" select="12"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="13"/>
				<xsl:with-param name="optiontext" select="13"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="14"/>
				<xsl:with-param name="optiontext" select="14"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="15"/>
				<xsl:with-param name="optiontext" select="15"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="16"/>
				<xsl:with-param name="optiontext" select="16"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="17"/>
				<xsl:with-param name="optiontext" select="17"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="18"/>
				<xsl:with-param name="optiontext" select="18"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="19"/>
				<xsl:with-param name="optiontext" select="19"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="20"/>
				<xsl:with-param name="optiontext" select="20"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="21"/>
				<xsl:with-param name="optiontext" select="21"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="22"/>
				<xsl:with-param name="optiontext" select="22"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="23"/>
				<xsl:with-param name="optiontext" select="23"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="24"/>
				<xsl:with-param name="optiontext" select="24"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="25"/>
				<xsl:with-param name="optiontext" select="25"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="26"/>
				<xsl:with-param name="optiontext" select="26"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="27"/>
				<xsl:with-param name="optiontext" select="27"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="28"/>
				<xsl:with-param name="optiontext" select="28"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="29"/>
				<xsl:with-param name="optiontext" select="29"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="30"/>
				<xsl:with-param name="optiontext" select="30"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="31"/>
				<xsl:with-param name="optiontext" select="31"/>
			</xsl:call-template>
		</select>
	</xsl:template>

	<!--
		Template: Month
		Purpose:  Builds a HTML select control for months as part of a date control
	-->
	<xsl:template name="month">
		<select>
			<xsl:attribute name="name"> M123 </xsl:attribute>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="1"/>
				<xsl:with-param name="optiontext" select="'Jan'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="2"/>
				<xsl:with-param name="optiontext" select="'Feb'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="3"/>
				<xsl:with-param name="optiontext" select="'Mar'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="4"/>
				<xsl:with-param name="optiontext" select="'Apr'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="5"/>
				<xsl:with-param name="optiontext" select="'May'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="6"/>
				<xsl:with-param name="optiontext" select="'Jun'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="7"/>
				<xsl:with-param name="optiontext" select="'Jul'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="8"/>
				<xsl:with-param name="optiontext" select="'Aug'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="9"/>
				<xsl:with-param name="optiontext" select="'Sep'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="10"/>
				<xsl:with-param name="optiontext" select="'Oct'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="11"/>
				<xsl:with-param name="optiontext" select="'Nov'"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="12"/>
				<xsl:with-param name="optiontext" select="'Dec'"/>
			</xsl:call-template>
		</select>
	</xsl:template>

	<!--
		Template: Year
		Purpose:  Builds a HTML text control for entering years as part of a date control.
	-->
	<xsl:template name="year">
		<input>
			<xsl:attribute name="type"> text </xsl:attribute>
			<xsl:attribute name="name"> YYYY </xsl:attribute>
			<xsl:attribute name="size"> 4 </xsl:attribute>
			<xsl:attribute name="maxlength"> 4 </xsl:attribute>
		</input>
	</xsl:template>

	<!--
		Template: Hour
		Purpose:  Builds a HTML select control for hours as part of a time control
	-->
	<xsl:template name="Hour">
		<select>
			<xsl:attribute name="name"> XXX </xsl:attribute>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="0"/>
				<xsl:with-param name="optiontext">00</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="1"/>
				<xsl:with-param name="optiontext">01</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="2"/>
				<xsl:with-param name="optiontext">02</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="3"/>
				<xsl:with-param name="optiontext">03</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="4"/>
				<xsl:with-param name="optiontext">04</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="5"/>
				<xsl:with-param name="optiontext">05</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="6"/>
				<xsl:with-param name="optiontext">06</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="7"/>
				<xsl:with-param name="optiontext">07</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="8"/>
				<xsl:with-param name="optiontext">08</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="9"/>
				<xsl:with-param name="optiontext">09</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="10"/>
				<xsl:with-param name="optiontext" select="10"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="11"/>
				<xsl:with-param name="optiontext" select="11"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="12"/>
				<xsl:with-param name="optiontext" select="12"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="13"/>
				<xsl:with-param name="optiontext" select="13"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="14"/>
				<xsl:with-param name="optiontext" select="14"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="15"/>
				<xsl:with-param name="optiontext" select="15"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="16"/>
				<xsl:with-param name="optiontext" select="16"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="17"/>
				<xsl:with-param name="optiontext" select="17"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="18"/>
				<xsl:with-param name="optiontext" select="18"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="19"/>
				<xsl:with-param name="optiontext" select="19"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="20"/>
				<xsl:with-param name="optiontext" select="20"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="21"/>
				<xsl:with-param name="optiontext" select="21"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="22"/>
				<xsl:with-param name="optiontext" select="22"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="23"/>
				<xsl:with-param name="optiontext" select="23"/>
			</xsl:call-template>
		</select>
	</xsl:template>

	<!--
		Template: Hour
		Purpose:  Builds a HTML select control for hours as part of a time control
	-->
	<xsl:template name="Minute">
		<select>
			<xsl:attribute name="name"> XXX </xsl:attribute>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="0"/>
				<xsl:with-param name="optiontext">00</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="1"/>
				<xsl:with-param name="optiontext">01</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="2"/>
				<xsl:with-param name="optiontext">02</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="3"/>
				<xsl:with-param name="optiontext">03</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="4"/>
				<xsl:with-param name="optiontext">04</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="5"/>
				<xsl:with-param name="optiontext">05</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="6"/>
				<xsl:with-param name="optiontext">06</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="7"/>
				<xsl:with-param name="optiontext">07</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="8"/>
				<xsl:with-param name="optiontext">08</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="9"/>
				<xsl:with-param name="optiontext">09</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="10"/>
				<xsl:with-param name="optiontext" select="10"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="11"/>
				<xsl:with-param name="optiontext" select="11"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="12"/>
				<xsl:with-param name="optiontext" select="12"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="13"/>
				<xsl:with-param name="optiontext" select="13"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="14"/>
				<xsl:with-param name="optiontext" select="14"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="15"/>
				<xsl:with-param name="optiontext" select="15"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="16"/>
				<xsl:with-param name="optiontext" select="16"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="17"/>
				<xsl:with-param name="optiontext" select="17"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="18"/>
				<xsl:with-param name="optiontext" select="18"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="19"/>
				<xsl:with-param name="optiontext" select="19"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="20"/>
				<xsl:with-param name="optiontext" select="20"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="21"/>
				<xsl:with-param name="optiontext" select="21"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="22"/>
				<xsl:with-param name="optiontext" select="22"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="23"/>
				<xsl:with-param name="optiontext" select="23"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="24"/>
				<xsl:with-param name="optiontext" select="24"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="25"/>
				<xsl:with-param name="optiontext" select="25"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="26"/>
				<xsl:with-param name="optiontext" select="26"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="27"/>
				<xsl:with-param name="optiontext" select="27"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="28"/>
				<xsl:with-param name="optiontext" select="28"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="29"/>
				<xsl:with-param name="optiontext" select="29"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="30"/>
				<xsl:with-param name="optiontext" select="30"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="31"/>
				<xsl:with-param name="optiontext" select="31"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="32"/>
				<xsl:with-param name="optiontext" select="32"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="33"/>
				<xsl:with-param name="optiontext" select="33"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="34"/>
				<xsl:with-param name="optiontext" select="34"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="35"/>
				<xsl:with-param name="optiontext" select="35"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="36"/>
				<xsl:with-param name="optiontext" select="36"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="37"/>
				<xsl:with-param name="optiontext" select="37"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="38"/>
				<xsl:with-param name="optiontext" select="38"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="39"/>
				<xsl:with-param name="optiontext" select="39"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="40"/>
				<xsl:with-param name="optiontext" select="40"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="41"/>
				<xsl:with-param name="optiontext" select="41"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="42"/>
				<xsl:with-param name="optiontext" select="42"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="43"/>
				<xsl:with-param name="optiontext" select="43"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="44"/>
				<xsl:with-param name="optiontext" select="44"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="45"/>
				<xsl:with-param name="optiontext" select="45"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="46"/>
				<xsl:with-param name="optiontext" select="46"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="47"/>
				<xsl:with-param name="optiontext" select="47"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="48"/>
				<xsl:with-param name="optiontext" select="48"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="49"/>
				<xsl:with-param name="optiontext" select="49"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="50"/>
				<xsl:with-param name="optiontext" select="50"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="51"/>
				<xsl:with-param name="optiontext" select="51"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="52"/>
				<xsl:with-param name="optiontext" select="52"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="53"/>
				<xsl:with-param name="optiontext" select="53"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="54"/>
				<xsl:with-param name="optiontext" select="54"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="55"/>
				<xsl:with-param name="optiontext" select="55"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="56"/>
				<xsl:with-param name="optiontext" select="56"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="57"/>
				<xsl:with-param name="optiontext" select="57"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="58"/>
				<xsl:with-param name="optiontext" select="58"/>
			</xsl:call-template>
			<xsl:call-template name="option">
				<xsl:with-param name="optionvalue" select="59"/>
				<xsl:with-param name="optiontext" select="59"/>
			</xsl:call-template>
		</select>
	</xsl:template>

	<!--
		Template: Option
		Purpose:  Builds an HTML option element for a select input.
	-->
	<xsl:template name="option">
		<xsl:param name="optionvalue"/>
		<xsl:param name="optiontext"/>
		<option>
			<xsl:attribute name="value">
				<xsl:value-of select="$optionvalue"/>
			</xsl:attribute>
			<xsl:value-of select="$optiontext"/>
		</option>
	</xsl:template>

	

</xsl:stylesheet>
