require "nexus_client/version"
require "nexus_client/gav"
require 'nexus_client/cache'
require 'nexus_client/analytics'
require "tmpdir"
require 'typhoeus'
require 'json'
require 'etc'
require 'fileutils'

module Nexus
  class Client
    attr_reader :host, :cache
    attr_accessor :use_cache, :log

    def initialize(nexus_host=nil, cache_dir='/tmp/cache', enable_cache=true, enable_analytics=false,logger=nil)
      @log = logger
      @host = nexus_host || default_host
      @host = @host.gsub(/\/nexus$/, '') # just in case user enters /nexus
      @use_cache = enable_cache
      if @use_cache
        @cache_base = cache_dir
        @cache = Nexus::Cache.new(@cache_base, enable_analytics, log)
      end
      #Typhoeus::Config.verbose = true

    end

    # read host will read ~/.nexus_host file and
    def read_host(filename="#{Etc.getpwuid.dir}/.nexus_host")
      fn = File.expand_path(filename)
      abort("Please create the file #{filename} and add your nexus host") if not File.exists?(filename)
      begin
        File.open(fn, 'r') { |f|  f.read }.strip
      rescue Exception => e
        raise(e)
      end
    end

    def default_host
      read_host
    end

    def log
      if @log.nil?
        @log = Logger.new(STDOUT)
      end
      @log
    end

    def self.download(destination, gav_str, cache_dir='/tmp/cache', enable_cache=false,enable_analytics=false,host=nil)
      client = Nexus::Client.new(host, cache_dir, enable_cache,enable_analytics)
      client.download_gav(destination, gav_str)
    end

    def download_gav(destination, gav_str)
      gav = Nexus::Gav.new(gav_str)
      download(destination, gav)
    end

  def create_target(destination)
    destination = File.expand_path(destination)
    if ! File.directory?(destination)
      begin
        FileUtils.mkdir_p(destination) if not File.exists?(destination)
      rescue SystemCallError => e
        raise e, 'Cannot create directory'
      end
    end

  end

    # retrieves the attributes of the gav
    def gav_data(gav)
      res = {}
      request = Typhoeus::Request.new(
        "#{host}/nexus/service/local/artifact/maven/resolve",
        :params  => gav.to_hash,:connecttimeout => 5,
        :headers => { 'Accept' => 'application/json' }
      )
      request.on_failure do |response|
        raise("Failed to get gav data for #{gav.to_s}")
      end
      request.on_complete do |response|
        res = JSON.parse(response.response_body)
      end
      request.run

      res['data']
    end

    # returns the sha1 of the file
    def sha(file, use_sha_file=false)
      if use_sha_file and File.exists?("#{file}.sha1")
        # reading the file is faster than doing a hash, so we keep the hash in the file
        # then we read back and compare.  There is no reason to perform sha1 everytime
        begin
          File.open("#{file}.sha1", 'r') { |f| f.read().strip}
        rescue
          Digest::SHA1.file(File.expand_path(file)).hexdigest
        end
      else
        Digest::SHA1.file(File.expand_path(file)).hexdigest
      end
    end

    # sha_match? returns bool by comparing the sha1 of the nexus gav artifact and the local file
    def sha_match?(file, gav, use_sha_file=false)
      if File.exists?(file)
        if gav.sha1.nil?
          gav.sha1 = gav_data(gav)['sha1']
        end
        sha(file,use_sha_file) == gav.sha1
      else
        false
      end
    end

    private

    # writes the sha1 a file if and only if the contents of the file do not match
    def write_sha1(file,sha1)
      shafile = "#{file}.sha1"
      File.open(shafile, 'w') { |f| f.write(sha1)  }
    end

    # downloads the gav to the destination, returns the file if download was successful
    # if cache is on then it will use the cache and if file is new will also cache the new file
    # TODO need a timeout when host is unreachable
    def download(destination, gav)
      raise 'Download destination must not be empty' if destination.empty?
      create_target(destination) # ensure directory path is created
      destination = File.expand_path(destination)
      if File.directory?(destination)
        dstfile = File.expand_path("#{destination}/#{gav.filename}")
      else
        dstfile = File.expand_path(destination)
      end
      # if the file already exists at the destination path than we don't need to download it again
      if sha_match?(dstfile, gav)
        # create a file that stores the sha1 for faster file comparisions later
        # This will only get created when the sha1 matches
        write_sha1("#{dstfile}", gav.sha1)
        if use_cache and not cache.exists?(gav)
          cache.add_file(gav, dstfile)
        end
        return true
      end
      # remove the previous sha1 file if it already exists
      FileUtils.rm("#{dstfile}.sha1") if File.exists?("#{dstfile}.sha1")

      if gav.sha1.nil?
        gav.sha1 = gav_data(gav)['sha1']
      end
      # use the cache if the file is in the cache
      if use_cache and cache.exists?(gav)
        cache_file_path = cache.file_path(gav)
        FileUtils.copy(cache_file_path, dstfile)
        cache.record_hit(gav)
      else
        request = Typhoeus::Request.new(
          "#{host}/nexus/service/local/artifact/maven/redirect",
          :params  => gav.to_hash,
          :connecttimeout => 5,
          :followlocation => true
        )
        request.on_failure do |response|
          raise("Failed to download #{gav.to_s}")
        end

        # when complete, lets write the data to the file
        # first lets compare the sha matches
        # if the gav we thought we downloaded has the same checksum, were are good
        request.on_complete do |response|
          File.open(dstfile, 'wb') { |f| f.write(response.body) } unless ! response.success?
          if not sha_match?(dstfile, gav, false)
            raise("Error sha1 mismatch gav #{gav.sha1} != #{sha(dstfile)}")
          end
          gav.attributes[:size] =  File.size(dstfile)
          gav.attributes[:total_time] =  response.options[:total_time]

          # lets cache the file if cache is on
          if use_cache
            cache.add_file(gav, dstfile)
          end
          dstfile
        end
        request.run
        dstfile
      end
      dstfile
    end
  end
end
