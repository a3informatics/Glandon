module DownloadHelpers

  TIMEOUT = 10
  PATH    = Rails.root.join("tmp/downloads")

  extend self

  def downloads
    Dir[PATH.join("*")]
  end

  def download
    downloads.first
  end

  def download_content
    wait_for_download
    File.read(download)
  end

  def wait_for_specific_download(filename)
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until download_contains?(filename)
    end
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
    # Repleace timeout mechanism wiht simple loop.
    #max = TIMEOUT * 10
    #(1..max).each do
      break if downloaded?
      sleep 0.1 
    end
  end

  def downloaded?
    #!downloading? && downloads.any?
    b = downloads.any? # Do this check first. Think there may have been a race condition.
    a = downloading? 
  puts "Downloading: #{a}. Downloads: #{b}. File: #{downloads.first}"
    return !a && b
  end

  def downloading?
    downloads.grep(/\.crdownload$/).any?
  end

  def download_contains?(filename)
    files = Dir.entries(PATH)
    files.include?(filename)
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end

  def copy_file_to_db(filename)
    source_file = PATH.join "#{filename}"
    dest_file = Rails.root.join "db/load/tmp/#{filename}"
    FileUtils.cp source_file, dest_file
  end

  def rename_file(filename, new_filename)
    source_file = PATH.join "#{filename}"
    dest_file = PATH.join "#{new_filename}"
    File.rename(source_file, dest_file)
  end

end