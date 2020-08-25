@VL-23
Feature: Verify that user can see welcome page before login

	#When accessing the URL to the system the user is on the login page displaying a Welcome.
	@TEST_VL-18
	Scenario: Verify that user can see welcome page before login
		    Given I am on login page
		    Then I should see "Welcome"
