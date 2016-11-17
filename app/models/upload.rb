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
    directory = Rails.root.join("public","upload")
    path = File.join(directory, name.original_filename)
    File.open(path, "wb") { |f| f.write(name.read) }
  end

end
