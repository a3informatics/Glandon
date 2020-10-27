module AuditTrailHelpers
  
  def check_audit_trail(results, count, sub_dir, filename, write_file=false)
    if write_file
      items = AuditTrail.order(date_time: :desc).first(count)
      puts colourize("***** WARNING: Writing Results File *****", "red")
      write_csv_file(items, sub_dir, filename)
    end
    keys = ["id", "date_time", "user", "owner", "identifier", "version", "event", "details", "created", "updated"]
    expected = CSV.read(test_file_path(sub_dir, filename)).map {|a| Hash[ keys.zip(a) ]}
    expect(results.count).to eq(expected.count-1) # Header row in CSV file
    results.each_with_index do |item, index|
      expect(item.user).to eq(expected[index + 1]["user"])
      expect(item.owner).to eq(expected[index + 1]["owner"])
      expect(item.identifier).to eq(expected[index + 1]["identifier"])
      expect(item.version).to eq(expected[index + 1]["version"])
      expect(item.event.to_s).to eq(expected[index + 1]["event"])
      expect(item.description).to eq(expected[index + 1]["details"])
    end
  end

  def last_audit_event
    item = AuditTrail.all.last
    item.attributes.deep_symbolize_keys.slice(:user, :owner, :identifier, :version, :event, :description)
  end

private

  def write_csv_file(data, sub_dir, filename)
    results = CSV.generate do |csv|
      csv << data[0].as_json.map{|k,v| k}
      data.each do |r|
        csv << r.as_json.map{|k,v| v}
      end
    end
    write_text_file_2(results, sub_dir, filename)
  end

end