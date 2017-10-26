module PermissionsHelpers

  def allow(action)
    expect(subject.public_send("#{action}?")).to eq(true)
  end

  def deny(action)
    expect(subject.public_send("#{action}?")).to eq(false)
  end

  def allow_list(action_list, display=false)
    action_list.each do |action|
    	puts "#{action}" if display
      allow(action)
    end
  end

  def deny_list(action_list, display=false)
    action_list.each do |action|
    	puts "#{action}" if display
      deny(action)
    end
  end

end