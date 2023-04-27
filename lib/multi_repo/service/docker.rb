module MultiRepo::Service
  class Docker
    def self.registry
      @registry ||= ENV.fetch("DOCKER_REGISTRY")
    end

    def self.registry=(endpoint)
      @registry = endpoint
    end

    def self.clear_cache
      FileUtils.rm_f(Dir.glob("/tmp/docker-*"))
    end

    SMALL_IMAGE = "hello-world:latest".freeze

    def self.ensure_small_image
      return @has_small_image if defined?(@has_small_image)

      return false unless system?("docker pull #{SMALL_IMAGE} &>/dev/null")

      @has_small_image = true
    end

    def self.tag_small_image(fq_path)
      return false unless ensure_small_image

      system?("docker tag #{SMALL_IMAGE} #{fq_path}") &&
        system?("docker push #{fq_path}") &&
        system?("docker rmi #{fq_path}")
    end

    def self.system?(command, dry_run: false, verbose: true)
      if dry_run
        puts "+ dry_run: #{command}".light_black
        true
      else
        puts "+ #{command}".light_black
        system(command)
      end
    end

    def self.system!(command, **kwargs)
      exit($?.exitstatus) unless system?(command, **kwargs)
    end

    attr_accessor :registry, :cache, :dry_run

    def initialize(registry: self.class.registry, cache: true, dry_run: false)
      require "rest-client"
      require "fileutils"
      require "json"

      @registry = registry

      @cache   = cache
      @dry_run = dry_run

      self.class.clear_cache unless cache
    end

    def tags(image, **kwargs)
      path = File.join("v2", image, "tags/list")
      cache_file = "/tmp/docker-tags-#{image.tr("/", "-")}-raw-#{Date.today}.json"
      request(:get, path, **kwargs).tap do |data|
        File.write(cache_file, JSON.pretty_generate(data))
      end["tags"]
    end

    def retag(image, new_image)
      system?("skopeo copy --multi-arch all docker://#{image} docker://#{new_image}", dry_run: dry_run)
    end

    def delete_registry_tag(image, tag, **kwargs)
      path = File.join("v2", image, "manifests", tag)
      request(:delete, path, **kwargs)
      true
    rescue RestClient::NotFound => err
      # Ignore deletes on 404s because they are either already deleted or the tag is orphaned.
      raise unless err.http_code == 404
      false
    end

    def force_delete_registry_tag(image, tag, **kwargs)
      return true if delete_registry_tag(image, tag, **kwargs)

      # The tag is likely orphaned, so recreate the tag with a new image, then immediately delete it
      fq_path = File.join(registry, "#{image}:#{tag}")
      self.class.tag_small_image(fq_path) &&
        delete_registry_tag(image, tag, **kwargs)
    end

    def run(image, command, platform: nil)
      system_capture!("docker run --rm -it #{"--platform=#{platform} " if platform} #{image} #{command}")
    end

    def fetch_image_by_sha(source_image, image_tag, platform: nil)
      source_image_name, source_image_sha = source_image.split("@")
      source_image_sha = source_image_sha.split(":").last
      image = "#{source_image_name}:#{image_tag}"

      system!("docker pull #{"--platform=#{platform} " if platform}#{source_image}")
      system!("docker tag #{source_image} #{image}")

      image
    end

    def remove_images(*images)
      command = "docker rmi #{images.join(" ")}"

      # Don't use system_capture! as this is expected to fail if the image does not exist.
      if dry_run
        puts "+ dry_run: #{command}".light_black
      else
        puts "+ #{command}".light_black
        `#{command} 2>/dev/null`
      end
    end

    def manifest_inspect(image)
      command = "docker manifest inspect #{image}"

      cache_file = "/tmp/docker-manifest-#{image.split("@").last}.txt"
      if cache && File.exist?(cache_file)
        puts "+ cached: #{command}".light_black
        data = File.read(cache_file)
      else
        data = system_capture(command)
        File.write(cache_file, data)
      end

      data.blank? ? {} : JSON.parse(data)
    end

    private

    def request(verb, path, body: nil, headers: {}, verbose: true)
      path = File.join(registry, path)

      if dry_run && %i[delete put post patch].include?(verb)
        puts "+ dry_run: #{verb.to_s.upcase} #{path}".light_black if verbose
        {}
      else
        puts "+ #{verb.to_s.upcase} #{path}".light_black if verbose
        response =
          if %i[put post patch].include?(verb)
            RestClient.send(verb, path, body, headers)
          else
            RestClient::Request.execute(:method => verb, :url => path, :headers => headers, :read_timeout => 300) do |response, request, result|
              if verb == :delete && response.code == 301 # Moved Permanently
                response.follow_redirection
              else
                response.return!
              end
            end
          end
        response.empty? ? {} : JSON.parse(response)
      end
    end

    def system?(command, **kwargs)
      self.class.system?(command, **kwargs)
    end

    def system!(command, **kwargs)
      self.class.system!(command, **kwargs)
    end

    def system_capture(command)
      puts "+ #{command}".light_black
      `#{command}`.chomp
    end

    def system_capture!(command)
      system_capture(command).tap do
        exit($?.exitstatus) if $?.exitstatus != 0
      end
    end
  end
end
