module NameValueHelpers

  def nv_create(params)
    NameValue.create(name: "thesaurus_parent_identifier", value: params[:parent])
    NameValue.create(name: "thesaurus_child_identifier", value: params[:child])
  end

  def nv_destroy
    NameValue.destroy_all
  end

  def nv_predict_parent
    NameValue.where("name='thesaurus_parent_identifier'").first.value.to_i
  end

  def nv_predict_child
    NameValue.where("name='thesaurus_child_identifier'").first.value.to_i
  end

end