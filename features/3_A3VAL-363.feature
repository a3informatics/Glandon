@A3VAL-1091
Feature: Validation R3.9.4: Test Execution for Test Plan A3VAL-456 (Community)

	Background:
		#@A3VAL-1098
		Given I am signed in successfully as "Admin"

	#The objective is to verify that a user with System Admin role can lock and un-lock other users.
	@A3VAL-363 @A3VAL-1108
	Scenario: User management - lock/un-lock users
		When I access the Manage users menu from the top navigation bar
		Then I see the Users management page
		When I click on the lock for the "Community Reader" Role
		Then I see the message "User was successfully deactivated"
		When I log off as "Admin"
		And I try to log on as "Community Reader" 
		Then I see the message "Your account is locked"
		When I log on as "Admin"
		And I access the Manage users menu from the top navigation bar
		And I click on the unlock for the "Community Reader" Role
		Then I see the message "User was successfully activated"
		When I log off as "Admin"
		And I log on as "Community Reader"
		Then I see the message "Signed in successfully"
