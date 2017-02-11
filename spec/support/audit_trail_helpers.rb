module AuditTrailHelpers
  
  def check_audit_trail(filename)
    items = AuditTrail.all
    keys = ["datetime", "user", "owner", "identifier", "version", "event", "details"]
    expected = CSV.read(test_file_path(sub_dir, filename)).map {|a| Hash[ keys.zip(a) ]}
    items.each_with_index do |item, index|
      #expect(Timestamp.new(item.date_time).to_datetime).to eq(expected[index + 1]["datetime"]) # Timestamps will not match
      expect(item.user).to eq(expected[index + 1]["user"])
      expect(item.owner).to eq(expected[index + 1]["owner"])
      expect(item.identifier).to eq(expected[index + 1]["identifier"])
      expect(item.version).to eq(expected[index + 1]["version"])
      expect(item.event_to_s).to eq(expected[index + 1]["event"])
      expect(item.description).to eq(expected[index + 1]["details"])
    end
  end

end