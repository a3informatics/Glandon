Feature: CDISC Terminology - reader display

	Background:
		#@A3VAL-461
		Given the latest version of CDISC has Version Label: "2020-06-26 Release" and Version Number: "65.0.0" 
		
		#@A3VAL-454
		Given I am signed in successfully as "Community Reader"


	#The objective is to verify that a community user can browse code list versions and display a specific code list and code list items.
	@A3VAL-412
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
