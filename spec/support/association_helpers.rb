module AssociationHelpers
  
  def create_association(semantic, subject, associated_with)
    associated_with = associated_with.is_a?(Array) ? associated_with : [associated_with]
    association = Association.create({semantic: semantic, subject: subject, associated_with: associated_with})
  end

end