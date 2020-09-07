module Helper
   include WaitForAjaxHelper
   include ViewHelpers
   include UiHelpers
   include ScenarioHelpers
   include PauseHelpers
   include Capybara::DSL
   end #end Module  
World(Helper)