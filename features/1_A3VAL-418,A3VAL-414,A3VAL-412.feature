@A3VAL-1091
Feature: Validation R3.9.4: Test Execution for Test Plan A3VAL-456 (Community)

	Background:
		#@A3VAL-454
		Given I am signed in successfully as "Community Reader"
		#@A3VAL-461
		Given the latest version of CDISC has Version Label: "2020-06-26 Release" and Version Number: "65.0.0"

	#The objective is to verify that the community reader can view changes between two selected code lists and changes to code list across all CDISC terminology versions.
	@A3VAL-418
	Scenario: CDISC Terminology - changes between versions - community reader
		Given I am on Community Dashboard
		When I click "See the changes across versions"
		Then I see Controlled Terminology Changes Across versions displayed
		When I enter "C99079" in the search area click "Changes" to display the "EPOCH" code list
		Then I see the differences in the "EPOCH" code list is displayed
		And the changes to the "EPOCH" code list items
		And the Differences panel has 10 entries and no updates to Submission Value, Preferred Term, Synonym or Definition
		When I click "Start" at the bottom of the page
		Then the Changes panel displays 9 entries
		And the "Therapeutic Procedure", c-code: "C49236" was created (+) in version "2011-12-09" and deleted (-) in version "2012-08-03"
		When I sort on version "2012-08-03" in the Changes table
		Then the code list item "Treatment Epoch", c-code: "C101526" and "Therapeutic Procedure", c-code: "C49236" is displayed as the first two rows
		When I click "PDF Report" in the top of the page
		Then a PDF report for C-code: "C99079" is generated and contains the 9 entries in the Changes panel
		When I click "Changes" at the item "Therapeutic Procedure" 
		Then the Differences panel is displayed
		And  the Differences panel displays 2 entries
		When I click Return
		Then I see the differences in the "EPOCH" code list is displayed
		And the changes to the "EPOCH" code list items
		When I click Home
		Then I am on Community Dashboard
		When I select CDISC version "2019-03-29" and CDISC version "2019-06-28" by dragging the slides and click Display
		Then I see 25 code lists created, 75 code lists updated, 1 code list deleted
		When I access the created "BIRRMRS", c-code:"C160927" by right-clicking and open in new tab
		Then I see the Differences and Changes for the "BIRRMRS" code list for CDISC version "2019-03-29" and CDISC version "2019-06-28"
		When I return on "CDISC Terminology Changes - A3 MDR" (previous tab)
		And I access the updated "PKPARMCD", c-code:"C85839" by right-clicking and open in new tab
		Then I see the Differences and Changes for the "PKPARMCD" code list for CDISC version "2019-03-29" and CDISC version "2019-06-28"
		When I sort on version "2019-06-28" in the Changes table
		Then I see that 4 new codes were created "(+)" in version "2019-06-28"
		When I return on "CDISC Terminology Changes - A3 MDR" (previous tab)
		And I access the deleted "TDIGRP", c-code:"C66787" by right-clicking and open in new tab
		Then I see the Differences and Changes for the "TDIGRP" code list for CDISC version "2019-03-29" and CDISC version "2019-06-28"
		And I see that code list and code list items are maked deleted "(x)" in version "2019-06-28"
	#The objective is to verify that the community user can view submission value changes across all CDISC terminology versions
	@A3VAL-414
	Scenario: CDSIC Terminology - changes submission values - community reader
		When I click "See submission value changes across versions" button
		Then I see Submission value changes displayed
		When I enter "C127403" in the search area click "Changes" to display the "C127403" code list
		Then code list item "C127403" differences is displayed
		When I click Return
		Then I see Submission value changes displayed
		When I click "PDF Report" at the top of the page
		Then a PDF report is generated and contains the 104 entries in the Submission value changes panel
		When I click Home
		Then the Community Dashboard is displayed
	#The objective is to verify that a community user can browse code list versions and display a specific code list and code list items.
	@A3VAL-412
	Scenario: CDISC Terminology - community reader display 
		Given I am on Community Dashboard
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
		And  I click Home in the top navigation bar
		Then the Community Dashboard is displayed
		When I click "Browse latest version of CDISC CT"
		Then I see the list of code lists included in the latest release version as specified in pre-condition
