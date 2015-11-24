module BridgSdtm

	@@map = { 
		"DefinedObservation.nameCode.CD.code" => "--TESTCD",
		"DefinedObservation.nameCode.CD.originalText.ED.value" => "--TEST",
		"DefinedActivity.categoryCode.CD" => "--CAT",
		"DefinedActivity.subcategoryCode.CD" => "--SCAT",
		"PerformedObservationResult.value.ANY.value" => "--ORRES" ,
		"PerformedObservationResult.result.PQR.value" => "--ORRES" ,
		"PerformedClinicalResult.value.PQR.value" => "--ORRES" ,
		"DefinedObservation.bodyPositionCode.CD.code" => "--POS" ,
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
		"PerformedObservation.dateRange.IVL(TS.DATETIME).low.DSET(EN.ON).value" => "--DTC" ,
		"PerformedSpecimenCollection.dateRange.IVL(TS.DATETIME)" => "--ENDTC" ,
		"PerformedObservation.studyDayRange.IVL(INT)" => "--DY" ,
		# "PlannedSubjectActivityGroup.name.ST" => "--TPT" ,
		"PlannedContingentOnRelationship" => "--ELTM" ,
		"DefinedActivity.nameCode.CD" => "--TPTREF" ,
		"PerformedActivity.dateRange.IVL(TS.DATETIME)" => "--RFTDTC" }

	def BridgSdtm.get(bridg)
		if @@map.has_key?(bridg) 
			return @@map[bridg]
		else
			return ""
		end
	end
	
end