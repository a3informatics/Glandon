# Rake Display. Simple Module for Terminal Display. 
#  To only be used for rake tasks.
#
# @author Dave Iberson-Hurst
# @since 3.9.1
module RakeFile

  # Write dtaa as YAML file
  def write_data_as_yaml(data, filename_prefix)
    time_now = Time.now.strftime("%FT%H-%M-%S")
    full_path = Rails.root.join "public/test/#{filename_prefix}_#{time_now}.yaml"
    File.open(full_path, "w+") do |f|
      f.write(data.to_yaml)
    end
  end

end