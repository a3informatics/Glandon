module DataHelpers

	def clear_triple_store
		sparql_query = "PREFIX tst: <http://www.assero.co.uk/test/>\n" +
      "PREFIX dc: <http://purl.org/dc/elements/1.1/>\n" +
      "DELETE { ?a ?b ?c } WHERE { ?a ?b ?c }"
  	CRUD.update(sparql_query)
  end

  def load_triple_store(filename)
		full_path = Rails.root.join "db/load/test/#{filename}"
  	CRUD.file(full_path)
  end

end