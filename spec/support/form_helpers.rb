module FormHelpers
  
  def create_form(identifier, label)
    form = Form.create(label: label, identifier: identifier)
  end

end