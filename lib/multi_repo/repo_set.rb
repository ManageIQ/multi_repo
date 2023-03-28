require 'yaml'

module MultiRepo
  class RepoSet
    def self.config_files
      Dir.glob(MultiRepo.config_dir.join("repo_set*.yml")).sort
    end

    def self.config
      @config ||= config_files.each_with_object({}) do |f, h|
        config = YAML.unsafe_load_file(f)
        raise "#{f} must contain a Hash of repo set names to an Array of repo names" unless config.kind_of?(Hash) && config.values.all? { |v| v.kind_of?(Array) }
        h.merge!(YAML.unsafe_load_file(f))
      end
    end

    def self.[](set_name)
      all[set_name]
    end

    def self.all
      @all ||= config.transform_values { |repos| Array(repos).map { |r| Repo.new(r) } }
    end
  end
end
