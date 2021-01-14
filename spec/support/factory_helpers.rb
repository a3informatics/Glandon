module FactoryHelpers
  
  def fill_params(params, data)
    data.each {|x| params[x[:key]] = params.key?(x[:key]) ? params[x[:key]] : x[:value] }
  end
  
end