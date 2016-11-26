module FeatureHelpers
  
  def set_focus(field_id)
    page.execute_script %Q{ $('##{field_id}').trigger('focus') }
  end

end