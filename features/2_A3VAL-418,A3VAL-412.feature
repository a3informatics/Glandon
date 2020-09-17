@A3VAL-460
Feature: Test Execution for Test Plan A3VAL-456

	Background:
		#@A3VAL-454
		Given I am signed in successfully as "Community Reader"
		#@A3VAL-461
		Given the latest version of CDISC has Version Label: "2020-06-26 Release" and Version Number: "65.0.0"

	#The objective is to verify that the user can view changes between two selected code lists and changes to code list across all CDISC terminology versions.
	@A3VAL-418 @A3VAL-455
	Scenario: CDISC Terminology - changes
		Given I am on Dashboard
		When I click "See the changes across versions"
		Then I see Controlled Terminology Changes Across versions displayed
		When I enter "C99079" in the search area click "Changes" to display the "EPOCH" code list
		Then I see the differences in the "EPOCH" code list is displayed
		And the changes to the "EPOCH" code list items
		And the Differences panel has 10 entries and no updates to Submission Value, Preferred Term, Synonym or Definition
		When I click "Start" at the bottom of the page
		Then the Changes panel displays 12 entries
		And the "Theraputic Procedure", c-code: "C49236" was created (+) in version "2011-12-09" and deleted (-) in version "2012-08-03"
		When I sort on version "2012-08-03" in the Difference table
		Then the code list item "Treatment Epoch", c-code: "C101526" and "Theraputic Procedure", c-code: "C49236" is displayed as the first two rows
		When I click "PDF Report" in the top of the page
		Then a PDF report is generated and contains the 12 entires in the Changes panel
		When I click Changes for the "Theraputic Procedure", c-code: "C49236"
		Then the Differences panel is displayed
		And 2 changes are displayed
		When I click Return
		Then I see the differences in the "EPOCH" code list is displayed
		And the changes to the "EPOCH" code list items
		When I click Return
		Then I am on Dashboard
		When I select CDISC version "2019-03-29" and CDISC version "2019-06-28" by dragging the slides and click Display
		Then I see 25 code lists created, 75 code lists updated, 1 code list deleted
		When I access the created "SDTM IG", c-code:"C160924" by right-clicking and open in new tab
		Then I see the Differences and Changes for the "SDTMIGRS" code list for CDISC version "2019-03-29" and CDISC version "2019-06-28"
		When I return on Dashbaord (previous tab)
		And I access the updated "PK Parameters", c-code:"C85839" by right-clicking and open in new tab
		Then I see the Differences and Changes for the "PKPARMCD" code list for CDISC version "2019-03-29" and CDISC version "2019-06-28"
		When I sort on version "2019-06-28"
		Then I see that 4 new codes were created "(+)" in version "2019-06-28"
		When I return on Dashbaord (previous tab)
		And I access the deleted "Diagnosis Group", c-code:"C66787" by right-clicking and open in new tab
		Then I see the Differences and Changes for the "TDIGRP" code list for CDISC version "2019-03-29" and CDISC version "2019-06-28"
		And I see that code list and code list items are maked deleted "(x)" in version "2019-06-28"
		
	#The objective is to verify that a community user can browse code list versions and display a specific code list and code list items.
	@A3VAL-412 @A3VAL-455
	Scenario: CDISC Terminology - reader display
		Given I am on Dashboard
				            When I click "Browse every version of CDISC CT"
				            Then I see CDISC Terminology History page is displayed 
				            And the latest release version is as specified in pre-condition
				            When I click Context menu for "2019-06-28"
				            Then I verify that Show and Search are enabled and all other menus are disabled for "2019-06-28"
				            When I click "Show" in context menu for "2019-06-28" on the History page 
				            Then I see the list of code lists for the "2019-06-28 Release"
				            And the release has 891 entries/code lists
				            When I enter "C66729" in the Code lists search area and click "Show" to display the "ROUTE" code list
				            Then I see the items in the "ROUTE" code list is displayed
				            And the list has 132 entries
				            When I enter "C38299" in the Code List Items search area and click "Show" to display the "SUBCUTANEOUS" code list item
				            Then I see the "SUBCUTANEOUS" code list item
				            And I see that the shared Preferred terms are displayed as "CMROUTE" and "EXROUTE"
				            And I see that the shared Synonyms are displayed as "CMROUTE" and "EXROUTE"
				            When I click "Change instructions" in the context menu (on top left corner of the page)
				            Then I see that "No Change Instructions were found."
				            And that it is not possible to add any "change instruction"
				            When I click "close"
				            And  click "Home" in the top navigation bar
				            Then the Dashbaord is displayed
				            When I click "Browse latest version" button
				            Then I see the list of code lists included in the latest release version as specified in pre-condition
