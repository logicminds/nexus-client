require 'json'

module Nexus
  class Analytics
    attr_reader :db, :data, :db_file
    attr_accessor :a_file, :log

    # new method
    def initialize(database_dir='./',db_filename='cache-analytics.db', logger=nil)
      @log = logger

      filename ||= db_filename || 'cache-analytics.db'

      log.warn "Filename is nil" if filename.nil?
      @db_file = File.join(database_dir,filename)
      begin
        require 'sqlite3'
        @db = SQLite3::Database.new( @db_file)
        init_tables
        total_view
      rescue LoadError => e
        log.error 'The sqlite3 gem must be installed before using the analytics class'
        raise(e.message)
      end
    end

    def log
      if @log.nil?
        @log = Logger.new(STDOUT)
      end
      @log
    end

    def add_item(gav, file_path)
      begin
        db.execute("insert into artifacts (sha1,artifact_gav,filesize,request_time, modified, file_location) "+
                     "values ('#{gav.sha1}','#{gav.to_s}', #{gav.attributes[:size]}, #{gav.attributes[:total_time]},"+
                     "'#{Time.now.to_i}', '#{file_path}')")
      rescue
        log.warn("Ignoring Duplicate entry #{file_path}")
      end

    end

    def gavs
      db.execute("select artifact_gav from artifacts").flatten
    end

    def update_item(gav)
      count = hit_count(gav)
      db.execute <<SQL
      UPDATE artifacts SET hit_count=#{count + 1}, modified=#{Time.now.to_i}
      WHERE sha1='#{gav.sha1}'
SQL
    end

    def totals
      db.execute("select * from totals")
    end

    def total(gav)
      # TODO fix NoMethodError: undefined method `sha1' for #<String:0x7f1a0f387720>
      # when type is not a gav or sha1 is not available
      data = db.execute("select * from totals where sha1 = '#{gav.sha1}'")
      db.results_as_hash = false
      data
    end


    def hit_count(gav)
      row = db.execute("select hit_count from totals where sha1 = '#{gav.sha1}'").first
      if row.nil?
        0
      else
        row.first
      end
    end

    def total_time(gav)
      row = db.execute("select total_time_saved from totals where sha1 = '#{gav.sha1}'").first
      if row.nil?
        0
      else
        row.first
      end

    end

    def total_bytes(gav, pretty=false)
      row = db.execute("select total_bytes_saved from totals where sha1 = '#{gav.sha1}'").first
      if row.nil?
        0
      else
        if pretty
          Filesize.from("#{row.first} B").pretty
        else
          row.first
        end
      end

    end

    # returns the totals view as json
    # the results as hash returns extra key/values we don't want so
    # we had to create our own hash
    # there are better ways of doing this but this was simple to create
    def to_json(pretty=true)
      db.results_as_hash = false
      totals = db.execute("select * from totals")
      hash_total = []
      totals.each do |row|
        h = {}
        (0...row.length).each do |col|
          h[total_columns[col]] = row[col]
        end
        hash_total << h
      end
      if pretty
        JSON.pretty_generate(hash_total)
      else
        hash_total.to_json
      end
    end

    # removes old items from the database that are older than mtime
    def remove_old_items(mtime)
      db.execute <<SQL
      DELETE from artifacts where modified < #{mtime}
SQL
    end

    # get items older than mtime, defaults to 2 days ago
    def old_items(mtime=(Time.now.to_i)-(172800))
      data = db.execute <<SQL
        SELECT * from artifacts where modified < #{mtime}
SQL
      data || []
    end

    # returns the top X most utilized caches
    def top_x(amount=10)
      db.execute <<SQL
        SELECT * FROM totals
        ORDER BY hit_count desc
        LIMIT #{amount}
SQL
    end

    private

    def total_columns
      %w(sha1 artifact_gav filesize request_time modified file_location hit_count total_bytes_saved total_time_saved)
    end

    def artifact_columns
      %w(sha1 artifact_gav filesize, request_time hit_count modified file_location )

    end

    def init_tables
      # id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      db.execute <<SQL
      CREATE TABLE IF NOT EXISTS artifacts (
       sha1 VARCHAR(40) PRIMARY KEY NOT NULL,
       artifact_gav VARCHAR(255),
       filesize BIGINT default 0,
       request_time FLOAT default 0,
       hit_count INTEGER default 0,
       modified BIGINT default '#{Time.now.to_i}',
       file_location VARCHAR(255)
      );
SQL
    end

    def total_view
      db.execute <<SQL
        CREATE VIEW IF NOT EXISTS totals AS
        SELECT sha1, artifact_gav, filesize, request_time, modified, file_location,
               hit_count, sum(hit_count * filesize) AS 'total_bytes_saved',
        sum(hit_count * request_time) as 'total_time_saved'
        FROM artifacts
SQL
    end

   end
end

