module MultiRepo::Service
  class Artifactory
    def self.api_token
      @api_token ||= ENV.fetch("ARTIFACTORY_API_TOKEN")
    end

    def self.api_token=(token)
      @api_token = token
    end

    def self.api_endpoint
      @api_endpoint ||= ENV.fetch("ARTIFACTORY_API_ENDPOINT")
    end

    def self.api_endpoint=(endpoint)
      @api_endpoint = endpoint
    end

    def self.auth_header
      {"X-JFrog-Art-Api" => api_token}
    end

    attr_accessor :dry_run, :cache

    def initialize(dry_run: false, cache: true)
      require 'rest-client'

      @dry_run = dry_run
      @cache   = cache
    end

    def clear_cache
      FileUtils.rm_f(Dir.glob("/tmp/artifactory-*"))
    end

    # https://www.jfrog.com/confluence/display/JFROG/RPM+Repositories
    def get(path, **kwargs)
      path = path.to_s
      request(:get, path, **kwargs)
    end

    def list(folder, cache: @cache, **kwargs)
      folder = folder.to_s
      cache_file = "/tmp/artifactory-#{folder.tr("/", "_")}-#{Date.today}.txt"
      if cache && File.exist?(cache_file)
        File.readlines(cache_file, :chomp => true)
      else
        data = raw_list(folder, cache: cache, **kwargs)
        uri  = data["uri"]

        data["files"].map { |d| File.join(uri, d["uri"]) }.tap do |d|
          File.write(cache_file, d.join("\n")) if cache
        end
      end
    end

    def raw_list(folder, cache: @cache, **kwargs)
      folder = folder.to_s
      cache_file = "/tmp/artifactory-#{folder.tr("/", "_")}-raw-#{Date.today}.json"
      if cache && File.exist?(cache_file)
        JSON.parse(File.read(cache_file))
      else
        get("/api/storage/#{folder}?list&deep=1", **kwargs).tap do |d|
          File.write(cache_file, JSON.pretty_generate(d)) if cache
        end
      end
    end

    def delete(file, **kwargs)
      file = file.to_s
      request(:delete, strip_api_prefix(file), **kwargs)
    rescue RestClient::NotFound => err
      # Ignore deletes on a 404 because it's already deleted
      raise unless err.http_code == 404
    end

    def move(file, to, **kwargs)
      file = file.to_s
      to = to.to_s
      request(:post, File.join("/api/move", "#{strip_api_prefix(file)}?to=/#{strip_api_prefix(to)}"), **kwargs)
    end

    def copy(file, to, **kwargs)
      file = file.to_s
      to = to.to_s
      request(:post, File.join("/api/copy", "#{strip_api_prefix(file)}?to=/#{strip_api_prefix(to)}"), **kwargs)
    end

    private

    def request(verb, path, body: nil, headers: nil, verbose: true)
      headers ||= self.class.auth_header.merge(
        "Accept"       => "application/json",
        "Content-Type" => "application/json"
      )
      path = File.join(self.class.api_endpoint, path)

      puts "+ #{verb.to_s.upcase} #{path}".light_black if verbose
      if dry_run && %i[delete put post patch].include?(verb)
        puts "+ dry_run: #{verb.to_s.upcase} #{path}".light_black if verbose
        {}
      else
        response =
          if %i[put post patch].include?(verb)
            RestClient.send(verb, path, body, headers)
          else
            RestClient.send(verb, path, headers)
          end
        response.empty? ? {} : JSON.parse(response)
      end
    end

    def api_file_prefix
      File.join(self.class.api_endpoint, "api/storage")
    end

    def strip_api_prefix(path)
      path.start_with?(api_file_prefix) ? path.sub(api_file_prefix, "") : path
    end
  end
end
