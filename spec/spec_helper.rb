require "multi_repo"

# Prepare a clean directory for the repos
REPOS_DIR = Pathname.new(__dir__).join("repos").expand_path
MultiRepo.repos_dir = REPOS_DIR
FileUtils.rm_rf(MultiRepo.repos_dir)
FileUtils.mkdir_p(MultiRepo.repos_dir)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
