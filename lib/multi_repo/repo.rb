require 'ostruct'

module MultiRepo
  class Repo
    attr_reader :name, :config, :dry_run, :path

    def initialize(name, config: nil, dry_run: false)
      @name    = name
      @dry_run = dry_run
      @config  = OpenStruct.new(config || {})
      @path    = MultiRepo.repos_dir.join(name)
    end

    alias to_s inspect

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
