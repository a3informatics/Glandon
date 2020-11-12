module UploadHelpers

  def upload_path(sub_dir, filename)
    return "files/#{sub_dir}/#{filename}"
  end

end