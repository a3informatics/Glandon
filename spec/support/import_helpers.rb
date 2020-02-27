module ImportHelpers
  
  def import_type(text)
    @import_type = text
  end

  def import_hash(object)
    object.attributes.except!("created_at", "updated_at")
  end

  def compare_import_hash(result, expected, options={})
    default_options = {error_file: false}
    default_options = {output_file: false}
    options.reverse_merge(default_options)
    expected["background_id"] = result.background_id
    expected["id"] = result.id
    if options[:error_file]
      expected["error_file"].sub!(extract_filename(expected["error_file"], "errors"), extract_filename(result.error_file, "errors"))
      expected["error_file"].sub!("/Users/daveih/Documents/rails/Glandon", Rails.root.to_s)
    end
    if options[:output_file]
      expected["output_file"].sub!(extract_filename(expected["output_file"], "load"), extract_filename(result.output_file, "load"))
      expected["output_file"].sub!("/Users/daveih/Documents/rails/Glandon", Rails.root.to_s)
    end
    expect(import_hash(result)).to hash_equal(expected)
  end

private

  def extract_filename(text, type)
    return text[/#{@import_type}_\d+_#{type}/]
  end

end