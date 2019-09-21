module NameValueHelpers

  def nv_create(params)
    NameValue.create(name: "thesaurus_parent_identifier", value: params[:parent])
    NameValue.create(name: "thesaurus_child_identifier", value: params[:child])
  end

  def nv_destroy
    NameValue.destroy_all
  end

end