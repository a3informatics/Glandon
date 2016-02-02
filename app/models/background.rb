class Background < ActiveRecord::Base

  C_CLASS_NAME = "Background"

	def importCdiscTerm(params)

      # Create the background job status
      self.update(
      	description: "Import CDISC terminology file(s). Date: " + params[:date] + ", Internal Version: " + params[:version] + ".", 
      	status: "Building manifest file.",
      	started: Time.now())

      # Create manifest file
      manifest = Xml::buildCdiscTermImportManifest(params[:date], params[:version], params[:files])
      
      # Create the thesaurus (does not actually create the database entries).
      # Entries in DB created as part of the XSLT and load
      self.update(status: "Transforming terminology file.", percentage: 10)
      
      # Transform the files and upload. Note the quotes around the namespace & II but not version, important!!
      Xslt.execute(manifest, "thesaurus/import/cdisc/cdiscTermImport.xsl", 
        { :UseVersion => params[:version], :Namespace => "'" + params[:ns] + "'", 
          :SI => "'" + params[:si] + "'", :CID => "'" + params[:cid] + "'"}, "CT.ttl")
      
      # upload the file to the database. Send the request, wait the resonse
      self.update(status: "Loading file into database.", percentage: 50)
      publicDir = Rails.root.join("public","upload")
      outputFile = File.join(publicDir, "CT.ttl")
      response = CRUD.file(outputFile)

      # And report ...
      if response.success?
        self.update(status: "Complete. Successful import.", percentage: 100, complete: true, completed: Time.now())
      else
        self.update(status: "Complete. Unsuccessful import.", percentage: 100, complete: true, completed: Time.now())
      end
      
    end
    handle_asynchronously :importCdiscTerm

end
