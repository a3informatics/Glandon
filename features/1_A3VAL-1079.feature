@A3VAL-1080
Feature: Validation R3.9.1 - Test Execution for Test Plan A3VAL-1078

	Background:
		#@A3VAL-465
		Given I am signed in successfully as "Curator"

	#Test is checking that custom properties includes the new Display Order custom property and the existing properties.
	#
	#Tests that they can be edited.
	@A3VAL-1079
	Scenario: Custom Properties - includes Display Order
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi C100130"     
		Then I see the History page is displayed
		When I click Edit in context menu for the latest version of the "C100130" code list
		Then I see the items in the "C100130" code list is displayed
		And the following types of attributes for the code list is displayed:
		|Identifier,Submission Value,Preferred Term,Synonyms,Definition,Tags|
		When I click "Show Custom Properties" button
		Then the following types of attributes for the code list is displayed:
		|Identifier,Submission Value,Preferred Term,Synonyms,Definition,Tags,CRF Display Value,Display Order,Synonym Sponsor, ADaM Stage,DC Stage,ED Use,SDTM Stage|
		When I edit the following properties for "SC71384":
		|Identifier|SubmissionValue| PreferredTerm|Synonyms|
		|SC96658|BIOLOGICALLY RELATED|Biological Relative - updated|A sponsor synonym|
		Then I see Preferred Term is "Biological Relative - updated"
		And I see Synonyms is "A sponsor synonym"
		And I see the following attributes for "SC71384":
		|Identifier|SubmissionValue|PreferredTerm|Synonyms|Definition|Tags|CRFDisplayValue|DisplayOrder|SynonymSponsor|ADaMStage|DCStage|EDUse|SDTMStage|
		|SC71384|BIOLOGICALLY RELATED|Biological Relative - updated|A sponsor synonym|An individual that shares genetic makeup with another individual.|None|Biological Relative|||false|true|false|true|  
		When I edit the following custom properties for "SC71384":
		|Identifier|DisplayOrder|
		|SC96658|1|
		Then I see Display Order is "1"
		When I click "New item" button 
		Then I see a new code list item
		When I click "Show Custom Properties" button
		Then I fill in the following value for the new item
		|SubmissionValue|PreferredTerm|Synonym|Definition|CRFDisplayValue|DisplayOrder|SynonymSponsor|ADaMStage|DCStage|EDUse|SDTMStage|
		|NEW CODE ITEM | New Code Item|NI|A new sponsor term|New coded Item|1|A sponsor added synonym|false|true|false|true|
		When I click Return
		And I click Delete in context menu for the latest version of the "C100130" code list
		And I click "Yes" in the confirmation box
		Then the latest version of "C100130" is deleted
