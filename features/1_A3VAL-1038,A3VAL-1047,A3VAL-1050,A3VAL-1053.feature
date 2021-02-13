@A3VAL-1052
Feature: Test Execution for Test Plan A3VAL-1051

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
	#The objective of the test is to demonstrate that when a user (curator) edits a (master) code list that has a subset (or extension) linked to it then the user can upgrade the subset (extension) to link to this new version when editing the subset/extension.
	#1. user updates master code list
	#2. then edits the linked subset
	#3. then upgrade the draft subset to refer to latest version of master code list.
	@A3VAL-1053
	Scenario: Ability to move reference to master code list for Subsets and Extensions
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "MASTER CL - UPGRADE SUBSET TEST"     
		Then I see the History page is displayed
		When I click Show in context menu for the latest version of the "MASTER CL - UPGRADE SUBSET TEST" code list
		Then I see the items in the "MASTER CL - UPGRADE SUBSET TEST" code list is displayed
		When I click Subsets in the context menu
		Then I see the subset "SUBSET UPGRADE TEST" being linked to the master code list
		When I Close in the modal
		And I click Return
		Then I see the History page is displayed
		When I click Edit in context menu for the latest version of the "MASTER CL - UPGRADE SUBSET TEST" code list
		Then I see the items in the "MASTER CL - UPGRADE SUBSET TEST" code list is displayed
		When I click "New item" button 
		Then I see a new code list item
		Then I fill in the following value for the new item
		|SubmissionValue|PreferredTerm|Synonym|Definition|
		|TERM 3|Term 3| |For demo|
		When I click Return
		And When I click Show in context menu for the latest version of the "MASTER CL - UPGRADE SUBSET TEST" code list
		Then I see the items in the "MASTER CL - UPGRADE SUBSET TEST" code list is displayed
		When I click Subsets in the context menu
		Then no subsets are linked to the new versin of themaster code list
		When I Close in the modal
		And I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "NP004008P"     
		Then I see the History page is displayed
		When I click Edit in context menu for the latest version of the "NP004008P" code list
		Then I see the items in the "NP004008P" code list is displayed
		And the Source Code List dislpays 2 itmes
		When I click Upgrade in the context menu
		And click Yes in the modal
		Then the Source Code List dislpays 3 itmes
		When I access the "Code Lists" in the navigation bar
		Then I see "Code Lists" Index page is displayed
		When I click History on the index page for "MASTER CL - UPGRADE SUBSET TEST"     
		Then I see the History page is displayed
		When I click Show in context menu for the latest version of the "MASTER CL - UPGRADE SUBSET TEST" code list
		Then I see the items in the "MASTER CL - UPGRADE SUBSET TEST" code list is displayed
		When I click Subsets in the context menu
		Then I see the subset "SUBSET UPGRADE TEST" being linked to the master code list
		When I Close in the modal
