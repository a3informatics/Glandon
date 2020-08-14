
#TURN_ON_SCREEN_SHOT=false
TURN_ON_SCREEN_SHOT=true

Given('save_screen') do
if TURN_ON_SCREEN_SHOT 
 screenshot_and_save_page
 end

end
