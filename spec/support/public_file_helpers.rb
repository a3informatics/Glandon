module PublicFileHelpers

	def public_path(sub_dir, filename)
    return Rails.root.join "public/#{sub_dir}/#{filename}"
  end

  def public_file_exists?(sub_dir, filename)
    expect(File.exists?(Rails.root.join "public/#{sub_dir}/#{filename}")).to be(true)
  end

  def delete_all_public_files
    public_dir = Rails.root.join("public", "test")
    files = Dir.glob(public_dir + "*")
    files.each do |file|
      File.delete(file)
    end
  end

  def delete_public_file(sub_dir, filename)
    file = Rails.root.join "public/#{sub_dir}/#{filename}"
		File.delete(file)
  rescue => e
  end

  def copy_file_to_public_files(source_sub_dir, filename, dest_sub_dir)
  	source_file = Rails.root.join "spec/fixtures/files/#{source_sub_dir}/#{filename}"
  	dest_file = Rails.root.join "public/#{dest_sub_dir}/#{filename}"
  	FileUtils.cp source_file, dest_file
  end

  def copy_file_from_public_files(source_sub_dir, filename, dest_sub_dir)
  	source_file = Rails.root.join "public/#{dest_sub_dir}/#{filename}"
  	dest_file = Rails.root.join "spec/fixtures/files/#{source_sub_dir}/#{filename}"
  	FileUtils.cp source_file, dest_file
  end

end