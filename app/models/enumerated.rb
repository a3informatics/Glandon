class Enumerated < IsoConceptV2
  
  configure rdf_type: "http://www.assero.co.uk/Enumrated#Emumerated",
            base_uri: "http://#{ENV["url_authority"]}/ENUM",
            uri_unique: :label,
            cache: true

  validates :label, presence: true

  # def self.default(value_set, default)
  #   result = value_set.select {|x| x.label.upcase == default.upcase}
  #   return result[0] if result.length == 1
  #   raise Exceptions::ApplicationLogicError.new(message: "Failed to find default value #{default} in #{C_CLASS_NAME} object.")
  # end

end
