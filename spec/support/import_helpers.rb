module ImportHelpers
  
  def replace_rails_root(text)
    text.sub(Rails.root.to_s, "/Users/daveih/Documents/rails/Glandon")
  end

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
    actual = import_hash(result)
    if options[:error_file]
      expected["error_file"].sub!(extract_filename(expected["error_file"], "errors"), extract_filename(result.error_file, "errors"))
      actual["error_file"] = replace_rails_root(actual["error_file"])
    end
    if options[:output_file]
      expected["output_file"].sub!(extract_filename(expected["output_file"], "load"), extract_filename(result.output_file, "load"))
      actual["output_file"] = replace_rails_root(actual["output_file"])
    end
    expect(actual).to hash_equal(expected)
  end

private

  def extract_filename(text, type)
    return text[/#{@import_type}_\d+_#{type}/]
  end

end