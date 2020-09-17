@A3VAL-460
Feature: Test Execution for Test Plan A3VAL-456

	#The objective is to verify that a user can search within a selected CDISC terminology version.
	@A3VAL-419 @A3VAL-455
	Scenario: CDISC Terminology - search

	#The objective is to verify that a user can browse code list versions and display a specific code list and code list items.
	@A3VAL-417 @A3VAL-455
	Scenario: CDISC Terminology - display

	#The objective is to verify that a community reader user can search within a selected CDISC terminology version.
	@A3VAL-415 @A3VAL-455
	Scenario: CDISC Terminology - search

	#The objective is to verify that the community user can view submission value changes across all CDISC terminology versions
	@A3VAL-414 @A3VAL-455
	Scenario: CDSIC Terminology - changes submission values

	#The objective is to verify that the community user can view changes between two selected code lists and changes to code list across all CDISC terminology versions
	@A3VAL-413 @A3VAL-455
	Scenario: CDISC Terminology - changes

	#The objective is to verify that the user can view if a code list is an extension code list.
	@A3VAL-311 @A3VAL-459
	Scenario: Terminology Extensions - indicator

	#The objective is to verify that the number of sponsor-added terms in an extension is displayed in the extension code list and can be viewed when comparing versions of it
	@A3VAL-310 @A3VAL-455 @A3VAL-459
	Scenario: CDISC Terminology Extensions - count number

	#The objective is to verify that a non-extensible code list cannot be extended
	@A3VAL-309 @A3VAL-455 @A3VAL-459
	Scenario: CDISC Terminology Extensions - non-extensible list

	#The objective is to verify that a curator can create a sponsor specific extended code list from a CDISC non-extensible code list, which can contain items that are not part of the original CDISC code list.
	@A3VAL-308 @A3VAL-455 @A3VAL-459
	Scenario: CDISC Terminology Extensions - overwrite CDISC settings

	#The objective is to verify that a use can delete a code list extension
	@A3VAL-307 @A3VAL-455 @A3VAL-459
	Scenario: CDISC Terminology Extensions - delete

	#The objectify that a user can extend a CDISC code list with a CDISC or sponsor code list item
	@A3VAL-306 @A3VAL-455 @A3VAL-459
	Scenario: CDISC Terminology Extensions - create

	#The objective is to verify that CDISC code lists and code list items are tagged with one or more Tags displaying which standard they belong to.
	@A3VAL-294 @A3VAL-455
	Scenario: CDISC terminology - tags

	#The objective is to verify that entries within a code list can be displayed and display if the code list is extensible.
	@A3VAL-293 @A3VAL-455
	Scenario: CDISC terminology - code list items view

	#The objective is to verify that a user can search within a terminology version on 
	#- Code list number
	#- Code list item number
	#- Submission value
	#- Preferred term
	#- Synonym
	#- Definition
	#- Cross all the fields
	@A3VAL-292 @A3VAL-455
	Scenario: CDISC terminology - search

	#The objective is to verify that changes to submission values can be displayed across all versions.
	@A3VAL-291 @A3VAL-455
	Scenario: CDISC terminology - submission value changes

	#The objective is to verify that changes in CDISC terminology can be viewed
	#- between terminology versions
	@A3VAL-290 @A3VAL-455
	Scenario: CDISC terminology - changes between versions

	#The objective is to verify that changes in CDISC terminology can be viewed
	#- on code list level
	#- on individual code list items level
	@A3VAL-289 @A3VAL-455
	Scenario: CDISC terminology - changes

	#The objective is to verify that CDISC terminology versions can be viewed.
	@A3VAL-288 @A3VAL-455
	Scenario: CDISC terminology - view

	#The objective is to verify that a new version can be imported-with status set as standard.
	@A3VAL-287 @A3VAL-455
	Scenario: CDISC terminology - import

	#The objective is to verify that system allow for multiple versions of the CDISC terminology.
	@A3VAL-286 @A3VAL-455
	Scenario: CDISC terminology - version management

	#The objective is to verify that cross-references between CDISC code lists and code list item cannot be deleted.
	@A3VAL-284 @A3VAL-455
	Scenario: CDISC Terminology Cross-references - delete

	#The system shall allow for a version of the CDISC terminology to be deleted.
	@A3VAL-261 @A3VAL-455
	Scenario: CDISC - delete

