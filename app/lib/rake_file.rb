# Rake Display. Simple Module for Terminal Display. 
#  To only be used for rake tasks.
#
# @author Dave Iberson-Hurst
# @since 3.9.1
module RakeFile

  # Write dtaa as YAML file
  def write_data_as_yaml(data, filename_prefix)
    full_path = generate_filename(filename_prefix, "csv")
    File.open(full_path, "w+") do |f|
      f.write(data.to_yaml)
    end
  end

  # Write dtaa as CSV file
  def write_data_as_csv(data, headers, filename_prefix)
    full_path = generate_filename(filename_prefix, "csv")
    CSV.open(full_path, "wb") do |csv|
      csv << headers
      data.each do |hash|
        csv << hash.values
      end
    end
  end

  def generate_filename(filename_prefix, ext)
    time_now = Time.now.strftime("%FT%H-%M-%S")
    Rails.root.join "public/test/#{filename_prefix}_#{time_now}.#{ext}"
  end

end