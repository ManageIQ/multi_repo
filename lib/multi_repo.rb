require 'pathname'
require 'pp'

require 'logger'
require 'active_support'

require 'multi_repo/version'

require 'multi_repo/labels'
require 'multi_repo/repo'
require 'multi_repo/repo_set'

require 'multi_repo/service/artifactory'
require 'multi_repo/service/code_climate'
require 'multi_repo/service/docker'
require 'multi_repo/service/git'
require 'multi_repo/service/github'
require 'multi_repo/service/rubygems_stub'

require 'multi_repo/helpers/git_mirror'
require 'multi_repo/helpers/license'
require 'multi_repo/helpers/pull_request_blaster_outer'
require 'multi_repo/helpers/readme_badges'
require 'multi_repo/helpers/rename_labels'
require 'multi_repo/helpers/update_branch_protection'
require 'multi_repo/helpers/update_labels'
require 'multi_repo/helpers/update_milestone'
require 'multi_repo/helpers/update_repo_settings'

module MultiRepo
  def self.root_dir
    @root_dir ||= Pathname.new(Dir.pwd).expand_path
  end

  def self.root_dir=(dir)
    @root_dir = Pathname.new(dir).expand_path
  end

  def self.config_dir
    @config_dir ||= root_dir.join("config")
  end

  def self.repos_dir
    @repos_dir ||= root_dir.join("repos")
  end
end
