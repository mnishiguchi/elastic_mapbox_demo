ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/spec"

def file_dir
  File.join(Rails.root, "db", "data_files")
end


# Utility method to save a piece of data to the specified file.
# ---
# Usage:
#   save_to_file(photo_urls, "expected_photo_urls.rb")
def save_to_file(data, destination)
  path = File.join(file_dir, destination)
  File.write(path, data)
end

require "minitest/reporters"
Minitest::Reporters.use!
# [ Minitest::Reporters::SpecReporter.new ] # Enable document-style reporter.
