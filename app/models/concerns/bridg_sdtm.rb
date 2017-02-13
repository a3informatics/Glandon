module BridgSdtm

	C_CLASS_NAME = "BridgSdtm"

	@@map = { 
		"DefinedObservation.nameCode.CD.code" => "--TESTCD",
		"DefinedObservation.nameCode.CD.originalText.ED.value" => "--TEST",
		"DefinedActivity.categoryCode.CD" => "--CAT",
		"DefinedActivity.subcategoryCode.CD" => "--SCAT",
		# "PerformedObservationResult.value.ANY.value" => "--ORRES" ,
		"PerformedObservationResult.result.PQR.value" => "--ORRES" ,
		"PerformedClinicalResult.value.PQR.value" => "--ORRES" ,
		"PerformedClinicalResult.value.CD.code" => "--ORRES" ,
		"PerformedObservation.bodyPositionCode.CD.code" => "--POS" ,
		"DefinedObservation.targetAnatomicSiteCode.CD.code" => "--LOC" ,
		"PerformedObservationResult.value.ANY.units" => "--ORRESU" ,
		"PerformedObservationResult.result.PQR.code" => "--ORRESU" ,
		"PerformedClinicalResult.value.PQR.code" => "--ORRESU" ,
		# "ReferenceResult.value.ANY" => "--ORNRLO" ,
		# "ReferenceResult.value.ANY" => "--ORNRHI" ,
		"PerformedClinicalResult.value.ANY" => "--STRESC" ,
		"PerformedObservationResult.value.ANY" => "--STRESN" ,
		#{}"PerformedObservationResult.value.ANY" => "--STRESU" ,
		 "ReferenceResult.value.ANY" => "--STNRLO" ,
		# "ReferenceResult.value.ANY" => "--STNRHI" ,
		# "ReferenceResult.value.ANY" => "--STNRC" ,
		"PerformedClinicalResult.normalRangeComparisonCode.CD" => "--NRIND" ,
		"PerformedObservation.negationIndicator.BL.value" => "--STAT" ,
		"PerformedObservation.negationReason.DSET(SC).value" => "--REASND" ,
		"Organization.name.DSET(EN.ON)" => "--NAM" ,
		"DefinedObservation.nameCode.CD" => "--LOINC" ,
		"Biologic.code.CD" => "--SPEC" ,
		"Specimen.conditionCode.CD" => "--SPCCND" ,
		"PerformedObservation.methodCode.CD.code" => "--METHOD" ,
		"PerformedObservationResult.baselineIndicator.BL" => "--BLFL" ,
		"PerformedSpecimenCollection.fastingStatusIndicator.BL" => "--FAST" ,
		"PerformedClinicalInterpretation.toxicityTermCode.CD" => "--TOX" ,
		"PerformedClinicalInterpretation.toxicityGradeCode.CD" => "--TOXGR" ,
		"PlannedSubjectActivityGroup.sequenceNumber.INT.NONNEG" => "VISITNUM" ,
		# "PlannedSubjectActivityGroup.name.ST" => "VISIT" ,
		"PlannedActivity.studyDayRange.IVL(INT)" => "VISITDY" ,
		"PerformedObservation.dateRange.IVL_TS_DATETIME.low.TS_DATETIME.value" => "--DTC" ,
		"PerformedSpecimenCollection.dateRange.IVL(TS.DATETIME)" => "--ENDTC" ,
		"PerformedObservation.studyDayRange.IVL(INT)" => "--DY" ,
		# "PlannedSubjectActivityGroup.name.ST" => "--TPT" ,
		"PlannedContingentOnRelationship" => "--ELTM" ,
		"DefinedActivity.nameCode.CD" => "--TPTREF" ,
		"PerformedActivity.dateRange.IVL(TS.DATETIME)" => "--RFTDTC" }

	# Method to get SDTM map given BRIDG reference
  #
  # * *Args*    :
  #   - +bridg+ -> The BRIDG reference
  # * *Returns* :
  #   - The SDTM variable (generic -- prefixed), Returns "" if not found.
  def self.get(bridg)
		result = ""
		if @@map.has_key?(bridg)
			result = "#{@@map[bridg]}"
		end
		return result
	end
	
end