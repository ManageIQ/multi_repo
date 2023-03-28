require 'ostruct'

module MultiRepo
  class Repo
    def self.config_file
      MultiRepo.config_dir.join("repos.yml")
    end

    def self.config
      @config ||= begin
        file = config_file
        config = file.exist? ? YAML.unsafe_load_file(file) : {}
        raise "#{config_file} must contain a Hash" unless config.kind_of?(Hash)
        config
      end
    end

    attr_reader :name, :dry_run, :config, :path

    def initialize(name, dry_run: false)
      @name    = name
      @dry_run = dry_run
      @config  = OpenStruct.new(self.class.config.fetch(name, {}))
      @path    = MultiRepo.repos_dir.join(name)
    end

    def git
      @git ||= MultiRepo::Service::Git.new(path: path, clone_source: config.clone_source || "git@github.com:#{name}.git", dry_run: dry_run)
    end

    def chdir
      git # Ensures the clone exists
      Dir.chdir(path) { yield }
    end

    def short_name
      name.split("/").last
    end

    def write_file(file, content, **kwargs)
      if dry_run
        puts "** dry-run: Writing #{path.join(file).expand_path}".light_black
      else
        File.write(file, content, kwargs.merge(:chdir => path))
      end
    end

    def rm_file(file)
      return unless File.exist?(path.join(file))

      if dry_run
        puts "** dry-run: Removing #{path.join(file).expand_path}".light_black
      else
        chdir { FileUtils.rm_f(file) }
      end
    end

    def detect_readme_file
      chdir do
        %w[README.md README README.txt].detect do |f|
          File.exist?(f)
        end
      end
    end
  end
end
