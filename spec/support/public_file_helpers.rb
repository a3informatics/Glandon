module PublicFileHelpers

	def delete_all_public_files
    public_dir = Rails.root.join("public", "test")
    files = Dir.glob(public_dir + "*")
    files.each do |file|
      File.delete(file)
    end
  end

end