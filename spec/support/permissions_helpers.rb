module PermissionsHelpers

  def allow(action)
    expect(subject.public_send("#{action}?")).to eq(true)
  end

  def deny(action)
    expect(subject.public_send("#{action}?")).to eq(false)
  end

  def allow_list(action_list)
    action_list.each do |action|
      allow(action)
    end
  end

  def deny_list(action_list)
    action_list.each do |action|
      deny(action)
    end
  end

end