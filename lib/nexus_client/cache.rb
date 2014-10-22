require 'filesize'
require 'etc'

module Nexus
  class Cache
    attr_reader :cache_base, :analytics_enabled
    attr_accessor :analytics, :log

    def initialize(base_dir='/tmp/cache', enable_analytics=false, logger=nil)
      @analytics_enabled = enable_analytics
      @cache_base = base_dir
      @log = logger
      create_base
    end

    def analytics
      if analytics_enabled
        if @analytics.nil?
          begin
            @analytics = Nexus::Analytics.new(@cache_base, nil, log)
            if @analytics.nil?
              @analytics_enabled = false
              log.warn("Unable to create analytics class, skipping analytics and disabling analytics usage")
            end
          rescue
            log.warn("Unable to create analytics class, skipping analytics and disabling analytics usage")
            @analytics_enabled = false
            return @analytics
          end
        end
      end
      @analytics
    end


    def log
      if @log.nil?
        @log = Logger.new(STDOUT)
      end
      @log
    end

    def create_base
      if not File.exists?(@cache_base)
        FileUtils.mkdir_p(@cache_base)
      end
    end

    def init_cache_info(gav)
      if gav.attributes[:size].nil?
        gav.attributes[:size] =  File.size(file_path(gav))
      end
      if analytics_enabled
        analytics.add_item(gav, file_path(gav))
      end
    end

    def record_hit(gav)
      analytics.update_item(gav) if analytics_enabled
    end

    def add_file(gav, dstfile)
      if not File.exists?(location(gav))
        FileUtils.mkdir_p(location(gav))
      end
      if File.exists?(dstfile)
        FileUtils.copy(dstfile, file_path(gav))
        init_cache_info(gav)
      else
        log.warn "file #{dstfile } will not be cached as it doesn't exist"
      end

    end

    # location is the directory where the files should be cached
    def location(gav)
      File.join(cache_base, gav.dir_location)
    end

    # the file path of the gav, the name of the file is the <sha1>.cache
    def file_path(gav)
      if gav.sha1.nil?
        raise('Need sha1 for gav')
      end
      File.join(location(gav), "#{gav.sha1}.cache")
    end

    # is_cached? returns a bool true if the file is cached
    # the sha1 checksum should be the file name and if it exists, it means its cached
    def exists?(gav)
      file = file_path(gav)
      File.exists?(file)
    end

    # the fastest way to prune this is to use the local find command
    def prune_cache(mtime=15)
      # get old, unused entries and discard from DB and filesystem
      entries = remove_old_items(mtime)
      entries.each do |key, entry|
        FileUtils.rm_f(entry[:file])
      end
    end

  end
end