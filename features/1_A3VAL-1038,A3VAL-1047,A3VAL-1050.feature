@A3VAL-1049
Feature: Validation R3.8.0 - Test Execution for Test Plan A3VAL-1037

	Background:
		#@A3VAL-465
		Given I am signed in successfully as "Curator"

	#Test is checking that custom properties includes the new Synonym_Sponsor custom property and the existing properties.
	#
	#Tests that they can be edited.
	@A3VAL-1038
	Scenario: Custom Properties - includes Synonym_Sponsor
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
		|Identifier,Submission Value,Preferred Term,Synonyms,Definition,Tags,CRF Display Value,Synonym Sponsor, ADaM Stage,DC Stage,ED Use,SDTM Stage|
		When I edit the following properties for "SC71384":
		|Identifier|SubmissionValue| PreferredTerm|Synonyms|
		|SC96658|BIOLOGICALLY RELATED|Biological Relative - updated|A sponsor synonym|
		Then I see Preferred Term is "Biological Relative - updated"
		And I see Synonyms is "A sponsor synonym"
		And I see the following attributes for "SC71384":
		|Identifier|SubmissionValue|PreferredTerm|Synonyms|Definition|Tags|CRFDisplayValue|SynonymSponsor|ADaMStage|DCStage|EDUse|SDTMStage|
		|SC71384|BIOLOGICALLY RELATED|Biological Relative - updated|A sponsor synonym|An individual that shares genetic makeup with another individual.|None|Biological Relative||false|true|false|true|  
		When I edit the following custom properties for "SC71384":
		|Identifier|SynonymSponsor|
		|SC96658|An additional sponsor synonym|
		Then I see Sponsor Synonym is "An additional sponsor synonym"
		When I click "New item" button 
		Then I see a new code list item
		When I click "Show Custom Properties" button
		Then I fill in the following value for the new item
		|SubmissionValue|PreferredTerm|Synonym|Definition|CRFDisplayValue|SynonymSponsor|ADaMStage|DCStage|EDUse|SDTMStage|
		|NEW CODE ITEM | New Code Item|NI|A new sponsor term|New coded Item|A sponsor added synonym|false|true|false|true|
		When I click Return
		And I click Delete in context menu for the latest version of the "C100130" code list
		And I click "Yes" in the confirmation box
		Then the latest version of "C100130" is deleted
	#The objective is to test the functionality in the Document Control menu:
	#
	#* ability to reset a version to draft (Incomplete state) including any data dependencies (items sharing data)
	#* ability to fast forward to release (standard state) including any dependencies (item sharing data)
	@A3VAL-1047
	Scenario: State Model - Roll-backwards and forwards including data sharing items
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi C101858"     
		Then I see the History page is displayed
		When I click "Document control" in context menu for "C101858"
		Then I see the document control for the "C101858" code list
		And the code list is in "Standard" state
		When I tick With dependencies
		And I click on "Rewind to Draft" in the Document control
		Then the modal Confirm Status Change with Dependencies is displayed with 3 items in "Standard" state
		When I click on Confirm and Proceed
		Then I see message Changed Status of 3 items to "Incomplete"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi C101858"     
		Then I see the History page is displayed
		And the state is "Incomplete" on the History page for "C101858"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi SN003058"     
		Then I see the History page is displayed
		And the state is "Incomplete" on the History page for "SN003058"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi SN003059"     
		Then I see the History page is displayed
		And the state is "Incomplete" on the History page for "SN003059"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi C101858"     
		Then I see the History page is displayed
		When I click "Document control" in context menu for "C101858"
		Then I see the document control for the "C101858" code list
		And the code list is in "Incomplete" state
		When I tick With dependencies
		And I click on "Forward to Release" in the Document control
		Then the modal Confirm Status Change with Dependencies is displayed with 3 items in "Incomplete" state
		When I click on Confirm and Proceed
		Then I see message Changed Status of 3 items to "Standard"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi C101858"     
		Then I see the History page is displayed
		And the state is "Standard" on the History page for "C101858"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi SN003058"     
		Then I see the History page is displayed
		And the state is "Standard" on the History page for "SN003058"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi SN003059"     
		Then I see the History page is displayed
		And the state is "Standard" on the History page for "SN003059"
	#The objective is to test the functionality in the Document Control menu:
	#
	#* ability to reset a version to draft (Incomplete state)
	#* ability to fast forward to release (standard state)
	@A3VAL-1050
	Scenario: State Model - Roll-backwards and forwards excluding data sharing items
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi C101858"     
		Then I see the History page is displayed
		When I click "Document control" in context menu for "C101858"
		Then I see the document control for the "C101858" code list
		And the code list is in "Standard" state
		And I click on "Rewind to Draft" in the Document control
		Then I see message Changed Status to "Incomplete"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi C101858"     
		Then I see the History page is displayed
		And the state is "Incomplete" on the History page for "C101858"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi SN003058"     
		Then I see the History page is displayed
		And the state is "Standard" on the History page for "SN003058"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi SN003059"     
		Then I see the History page is displayed
		And the state is "Standard" on the History page for "SN003059"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi C101858"     
		Then I see the History page is displayed
		When I click "Document control" in context menu for "C101858"
		Then I see the document control for the "C101858" code list
		And the code list is in "Incomplete" state
		And I click on "Forward to Release" in the Document control
		Then I see message Changed Status to "Standard"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi C101858"     
		Then I see the History page is displayed
		And the state is "Standard" on the History page for "C101858"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi SN003058"     
		Then I see the History page is displayed
		And the state is "Standard" on the History page for "SN003058"
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "Sanofi SN003059"     
		Then I see the History page is displayed
		And the state is "Standard" on the History page for "SN003059"
