@VL-36
@VL-2
Feature: REQ-MDR-CT-010
  #REQ-MDR-CT-010 : The system shall allow for multiple versions of the CDISC terminology to be held within the system

  Background:
    #@VL-35
     Given I am on login page
            When I log in as Community Reader
            Then I am signed in successfully as "Community Reader"

  #The objective is to verify that a community user can browse code list versions and display a specific code list and code list items.
  @VL-34 @VL-24
  Scenario: CDISC Terminology – reader display 
     Given I am on Dashboard
            When I click "Browse every version of CDISC CT"
            Then I see CDISC Terminology History page is displayed 
            And the latest release version is 65.0.0
            When I click Context menu for "2019-06-28"
            Then I verify that Show and Search are enabled and all other menus are disabled for "2019-06-28"
            When I click "Show" in context menu for "2019-06-28"
            Then I see the list of code lists for the "2019-06-28 Release"
            And the release has 891 entries/code lists