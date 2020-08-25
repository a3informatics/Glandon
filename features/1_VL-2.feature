@VL-9
@REQ_VL-2
	#Tests REQ-MDR-CT-010 : The system shall allow for multiple versions of the CDISC terminology to be held within the system
	@TEST_VL-3 @TESTSET_VL-6
			Feature: As a A3 user, I want to access the login page
				  Scenario: Seeing the login page for A3
		    Given I am on login page
		    Then I should see "Welcome"
		
