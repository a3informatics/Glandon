module PublicFileHelpers

	def public_path(sub_dir, filename)
    return Rails.root.join "public/#{sub_dir}/#{filename}"
  end

  def public_file_exists?(sub_dir, filename)
    expect(File.exists?(Rails.root.join("public","#{sub_dir}","#{filename}"))).to be(true)
  end

  def public_file_does_not_exist?(sub_dir, filename)
    expect(File.exists?(Rails.root.join("public","#{sub_dir}","#{filename}"))).to be(false)
  end

  def read_public_yaml_file(sub_dir, filename)
    file = Rails.root.join("public","#{sub_dir}","#{filename}")
    return YAML.load_file(file)
  end

  # Deprecated
  def delete_all_public_files
    delete_all_public_test_files
  end

  def delete_all_public_test_files
    delete_all_files("test")
  end

  def delete_all_public_report_files
    delete_all_files("report")
  end

  def delete_all_public_export_files
    delete_all_files("exports")
  end

  def delete_public_file(sub_dir, filename)
    file = Rails.root.join("public","#{sub_dir}","#{filename}")
		File.delete(file)
  rescue => e
  end

  def copy_file_to_public_files(source_sub_dir, filename, dest_sub_dir)
  	source_file = Rails.root.join("spec","fixtures","files","#{source_sub_dir}","#{filename}")
  	dest_file = Rails.root.join("public","#{dest_sub_dir}","#{filename}")
  	FileUtils.cp source_file, dest_file
  end

  def copy_file_from_public_files(source_sub_dir, filename, dest_sub_dir)
  	source_file = Rails.root.join("public","#{source_sub_dir}","#{filename}")
  	dest_file = Rails.root.join("spec","fixtures","files","#{dest_sub_dir}","#{filename}")
  	FileUtils.cp source_file, dest_file
  end

  def copy_file_from_public_files_rename(source_sub_dir, filename, dest_sub_dir, new_filename)
    source_file = Rails.root.join("public","#{source_sub_dir}","#{filename}")
    dest_file = Rails.root.join("spec","fixtures","files","#{dest_sub_dir}","#{new_filename}")
    FileUtils.cp source_file, dest_file
  end

private

  def delete_all_files(sub_dir)
    public_dir = Rails.root.join("public", sub_dir)
    files = Dir.glob(public_dir + "*")
    files.each do |file|
      File.delete(file)
    end
  end

end
