require "multi_repo"
require "pathname"
require "fileutils"

SPEC_DATA = Pathname.new(__dir__).join("data").expand_path

# Prepare a clean root directory
MultiRepo.root_dir = Pathname.new(__dir__).join("root").expand_path
FileUtils.rm_rf(MultiRepo.root_dir)
FileUtils.mkdir_p(MultiRepo.root_dir.join("config"))
FileUtils.mkdir_p(MultiRepo.root_dir.join("repos"))

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
