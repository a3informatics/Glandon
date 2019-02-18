class SubjectUniquenessValidator < ActiveModel::Validator
  
  def validate(record)
    return if record.class.where({options[:attribute] => record.send(options[:attribute])}).empty?
    record.errors.add :base, 'An existing record exisits in the database'
  end
  
end