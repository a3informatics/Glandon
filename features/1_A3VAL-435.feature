Feature: CDISC and Sponsor terminology - search

	Background:
		#@A3VAL-465
		Given I am signed in successfully as "Curator"
		#@A3VAL-891
		Given Terminology version "2009-10-06" is set to current

	#The objective is to verify that a user can search within all current terminology (CDISC and Sponsor-defined)
	@A3VAL-435
	Scenario: CDISC and Sponsor terminology - search
		When I access the "Terminology" in the navigation bar
		Then I see "Terminology" Index page is displayed
		When I click "Search Terminologies" button
		Then I see the "Select Terminology" selector window
		When I enable "Select all current"
		And I click "Submit and Proceed"
		Then I see the Search current page
		When I enter "C85492" in the Code List 
		Then I see 0 search results
		When I enter "C66741" in the Code List
		Then I see 14 search results
		When I enter "OQ TEST" in the Definition
		Then I see 4 search result
