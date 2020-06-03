class Upload
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id
  
  def persisted?
    id.present?
  end
  
  # Upload a file
  #
  # @param upload [hash] Parameters containing the full filename (incl path) in the datafile key
  # @return null
  def self.save(upload)  
    name =  upload['datafile']
    path = full_path(name.original_filename)
    File.open(path, "wb") {|f| f.write(name.read)}
  end

  # Delete Multiple
  # 
  # @param params [Hash] hash containing the files.
  # @return [Void] no return
  def delete_multiple(params)
    params[:files].each do |i| 
      File.delete(self.class.full_path(i))
    end
  rescue => e
    msg = "Something went wrong deleting the files."
    ConsoleLogger.info(self.class.name, "delete_multiple", "#{msg}\n#{e}")
    errors.add(:base, msg)
  end

  # Delete All
  #
  # @return [Void] no return
  def delete_all
    FileUtils.rm_rf(Dir["#{self.class.upload_path}/*"])
  rescue => e
    msg = "Something went wrong deleting all files."
    ConsoleLogger.info(self.class.name, "delete_all", "#{msg}\n#{e}")
    errors.add(:base, msg)
  end

private

  # Upload path
  def self.upload_path
    Rails.root.join(APP_CONFIG['upload_files'])
  end

  # Full path
  def self.full_path(filename)
    File.join(upload_path, filename)
  end

end
