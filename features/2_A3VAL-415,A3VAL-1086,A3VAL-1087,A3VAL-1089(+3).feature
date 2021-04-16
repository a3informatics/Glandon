@A3VAL-1091
Feature: Validation R3.9.4: Test Execution for Test Plan A3VAL-456 (Community)

	Background:
		#@A3VAL-454
		Given I am signed in successfully as "Community Reader"

	#The objective is to verify that a community reader user can search within a selected CDISC terminology version.
	@A3VAL-415
	Scenario: CDISC Terminology - community reader search
		Given user is on Community Dashboard
		When I click "Browse every version of CDISC CT"
		Then I see CDISC Terminology History page is displayed
		When I enter "2019-09-27" in the search area and click "Search" in the context menu
		Then I see the Search Terminology page displayed for release "2019-09-27" version "61.0.0"
		When I enter "C100" in the overall search field
		Then there are "1,722" entries displayed in the table
		| FieldValue |
		| C100 |
		When I enter "SDTM" in the Preferred Term search field
		Then there are "1" entries displayed in the table
		| FieldValue |
		| RELSUB |
		When I click Clear All
		Then all search terminology fields are cleared
		When I enter "mg/L" in the Submission Value search field
		Then there are "2" entries displayed in the table
		| FieldValue |
		| mg/L |
		| mg/L FEU |
		When I click Clear All
		Then all search terminology fields are cleared
		When I enter "Age Unit" in the Code List Name search field
		Then there are "6" entries displayed in the table
		| FieldValue |
		| DAYS   |
		| HOURS  |
		| WEEKS  |
		| MONTHS |
		| YEARS  |
		| AGEU   |
		When I enter "day" in the Preferred Term search field
		Then there are "1" entries displayed in the table
		| FieldValue |
		| DAYS   |
		When I click Clear All
		Then all search terminology fields are cleared
		When I click Return
		Then I see CDISC Terminology History page is displayed
		When I click Return
		Then the Community Dashboard is displayed
		When I click "Browse every version of CDISC CT"
		Then I see CDISC Terminology History page is displayed
		When I enter "2013-10-04" in the search area and click "Search" in the context menu
		Then I see the Search Terminology page displayed for release "2013-10-04" version "36.0.0"
		When I enter "C29844" in the Item search field
		Then there are "2" entries displayed in the table
		| FieldValue |
		| C66781 |
		| C71620 |
		When I click Clear All
		Then all search terminology fields are cleared
		When I enter "unit" in the Code List Name search field
		Then there are "905" entries displayed in the table
		| FieldValue |
		| Showing 1 to 10 of 905 entries |
		When I enter "unit -vital" in the Code List Name search field
		Then there are "890" entries displayed in the table
		| FieldValue |
		| Showing 1 to 10 of 890 entries |
		When I enter "C -C66781" in the Code List search field
		Then there are "884" entries displayed in the table
		| FieldValue |
		| Showing 1 to 10 of 884 entries |
		When I click first row in table
		Then there are "524" entries displayed in the table
		| FieldValue |
		| Showing 1 to 10 of 524 entries |
		And all search terminology fields are cleared except code list which contains "C71620"
	#The objective is to verify that preferred terms are displayed for code lists and code list items.
	@A3VAL-1086
	Scenario: Preferred Terms - display (community)
		When I click "Browse every version of CDISC CT"
		Then I see CDISC Terminology History page is displayed
		When I click "Show" in context menu for "2015-12-18 Release" on the History page 
		Then I see the list of code lists for the "2015-12-18 Release"
		And the release has 561 entries/code lists
		When I enter "C7115" in the search area
		Then I see 4 code lists with following preferred terms 
		| No | CodeList | PreferredTerm |
		| 1  | C71153   | CDISC SDTM ECG Test Code Terminology   |
		| 2  | C71152   | CDISC SDTM ECG Test Name Terminology   |
		| 3  | C71151   | CDISC SDTM ECG Test Method Terminology |
		| 4  | C71150   | CDISC SDTM ECG Finding Terminology     |
		When I enter "C99077" in the Code lists search area and click "Show" to display the "CDISC SDTM Study Type Terminology" code list
		Then I see the items in the "CDISC SDTM Study Type Terminology" code list is displayed
		Then I see 3 code list items with following preferred terms 
		| No | CodeListItem | PreferredTerm |
		| 1  | C98722       | Expanded Access Study |
		| 2  | C98388       | Interventional Study |
		| 3  | C16084       | Observational Study |
	#The objective is to verify that code lists and code list items sharing preferred terms are displayed and can be accessed from the display.
	@A3VAL-1087
	Scenario: Preferred Terms - sharing (community)
		When I click "Browse every version of CDISC CT"
		Then I see CDISC Terminology History page is displayed
		When I click "Show" in context menu for "2016-03-25 Release" on the History page 
		Then I see the list of code lists for the "2016-03-25 Release"
		And the release has 572 entries/code lists
		When I enter "PKUNIT" in the Code lists search area and click "Show" to display the "CDISC SDTM Pharmacokinetic Parameter Unit of Measure Terminology" code list
		Then I see the items in the "CDISC SDTM Pharmacokinetic Parameter Unit of Measure Terminology" code list is displayed
		And  I see 671 code list items
		When I click "Show" at the item "C85754"
		Then I see preferred term "Nanomole per Kilogram" being shared with "UNIT (C71620)" codelist for the "pmol/g (C85754)" item
	#The objective is to verify that code lists and code list items sharing synonyms are displayed and can be accessed from the display.
	@A3VAL-1089
	Scenario: Terminology Synonyms -sharing (community)
		When I click "Browse every version of CDISC CT"
		Then I see CDISC Terminology History page is displayed
		When I click "Show" in context menu for "2015-06-26 Release" on the History page 
		Then I see the list of code lists for the "2015-06-26 Release"
		And the release has 504 entries/code lists
		When I enter "C99075" in the Code lists search area and click "Show" to display the "CDISC SDTM Portion/Totality Terminology" code list
		Then I see the items in the "CDISC SDTM Portion/Totality Terminology" code list is displayed
		And  I see 6 code list items
		When I click "Show" at the item "C78728"
		Then I see synonym "Many" being shared with "RELTYPE (C78737)" codelist for the "MANY (C78728)" item
		And I see synonym "Several" being shared with "RELTYPE (C78737)" codelist for the "MANY (C78728)" item
	#The objective is to verify that entries within a code list can be displayed and display if the code list is extensible.
	@A3VAL-1106
	Scenario: CDISC terminology - code list items view (community)
		When I click "Browse every version of CDISC CT"
		Then I see CDISC Terminology History page is displayed
		When I click "Show" in context menu for "2014-10-06 Release" on the History page 
		Then I see the list of code lists for the "2014-10-06 Release"
		And the release has 446 entries/code lists
		When I enter "10013" in the search area
		Then I see 10 code lists
		And I see code list "EQ-5D-3L TESTCD" is displayed
		And I see that the code list "EQ-5D-3L TESTCD" is not extensible
		When I click "Show" at the item "EQ-5D-3L TESTCD"
		Then I see the items in the "EQ-5D-3L TESTCD" code list is displayed
		And I see 6 code list items with following preferred terms 
		| No | CodeListItem | PreferredTerm                    |
		| 1  | C100397      | EQ-5D-3L - EQ VAS Score          |
		| 2  | C100396      | EQ-5D-3L - Anxiety or Depression |
		| 3  | C100395      | EQ-5D-3L - Pain or Discomfort    |
		| 4  | C100394      | EQ-5D-3L - Usual Activities      |
		| 5  | C100393      | EQ-5D-3L - Self-Care             |
		| 6  | C100392      | EQ-5D-3L - Mobility              |
		When I click Return
		And I click Return
		Then I see CDISC Terminology History page is displayed
	#The objective is to verify that the system supports that for a configured role (named community reader) the dashboard will display the history between two selected CDISC terminology versions: 
	#a.	Items added 
	#b.	Items changed 
	#c.	Items deleted
	@A3VAL-618
	Scenario: User Dashboard
		Given I am on on Community Dashboard
		When I select CDISC version "2020-05-08" and CDISC version "2020-06-26" by dragging the slides and click Display
		Then I see 9 code lists created, 55 code lists updated, 0 code list deleted
	#The objective is to verify that a user can change their password
	@A3VAL-339 @A3VAL-1108
	Scenario: Password management - change
		When I click "Settings" button
		Then I see the User Settings page
		When I enter current password
		And I enter new password
		And I enter confirm new password
		And I click Update button for password change
		Then I see the message "Your account has been updated successfully"
		When I log off as "Community Reader"
		And I log on as Community Reader with new password
		Then I am signed in successfully as Community Reader
