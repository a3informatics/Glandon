@A3VAL-1082
Feature: pPQ Sanofi PROD R3.9.1: Test Execution for Test Plan A3VAL-1081

	Background:
		#@A3VAL-465
		Given I am signed in successfully as "Curator"
		#@A3VAL-1026
		Given the Sanofi terminology "2019 Release 1" has been loaded and owner is Sanofi

	#The objective is to verify that the user can view the additional metadata attributes to a managed item or child element, e.g. additional attributes to a code list and a code list item.
	@A3VAL-976
	Scenario: Terminology - view of additional metadata attributes to a managed item or child element
		When I access the "Terminology" in the navigation bar
		Then I see "Terminology" Index page is displayed
		When I click History on the index page for "2019 Release 1"      
		Then I see the History page is displayed
		When I click "Show" in context menu for "2019 Release 1" on the History page 
		Then I see the list of code lists for the "2019 Release 1"
		When I enter "C100130" in the search area and click "Show" on the Code List page
		Then I see the items in the "C100130" code list is displayed
		And the list has 55 entries
		And the following types of attributes for the code list is displayed:
		|Identifier,Submission Value,Preferred Term,Synonyms,Definition,Tags|
		When I click "Show Custom Properties" button
		Then the following types of attributes for the code list is displayed:
		|Identifier,Submission Value,Preferred Term,Synonyms,Definition,Tags,CRF Display Value,Display Order, Synonym Sponsor,ADaM Stage,DC Stage,SDTM Stage|
		When I enter "C96658" in the search area
		Then I see the following attributes for "C96658" of 2019 Release 1:
		|Identifier|SubmissionValue|PreferredTerm|Synonyms|Definition|Tags|CRFDisplayValue|DisplayOrder|SynonymSponsor|ADaMStage|DCStage|SDTMStage|
		|C96658    |SISTER, BIOLOGICAL MATERNAL HALF|Half-sister with Mother as Common Parent|Half-sister with Mother as Common Parent|A female who shares with her sibling the genetic makeup inherited from only the biological mother.|SDTM|Biological Maternal Half Sister||Half-sister with Mother as Common Parent|false|true|true|
		When I click "Hide Custom Properties" button
		Then the following types of attributes for the code list is displayed:
		|Identifier,Submission Value,Preferred Term,Synonyms,Definition,Tags|
