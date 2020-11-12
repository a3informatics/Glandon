require 'rspec/expectations'

RSpec::Matchers.define :pundit_permit do |subject, action|  

  # Not working at present.
  match do |subject|
    subject.public_send("#{action}?")
  end

  failure_message do |subject|
    "#{subject.class} does not permit #{action} on #{subject.record} for #{subject.user.inspect}."
  end

  failure_message_when_negated do |subject|
    "#{subject.class} does not forbid #{action} on #{subject.record} for #{subject.user.inspect}."
  end

end