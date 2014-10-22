module Nexus
  class Gav
    attr_accessor :group, :artifact, :version, :repo, :classifier, :extension, :sha1, :attributes
    attr_reader :gav_value

    def initialize(gav_string)
      raise(err) if gav_match.match(gav_string).nil?
      @group,@artifact,@version,@repo,@classifier,@extension = gav_string.split(":")
      @gav_value = gav_string
      @attributes = {}
    end

    def to_s
      gav_value
    end

    def filename
      if classifier.empty?
        "#{artifact}-#{version}.#{extension}"
      else
        "#{artifact}-#{version}-#{classifier}.#{extension}"
      end
    end

    def to_hash
      {:g => group, :a => artifact, :v => version, :r => repo, :c => classifier, :e => extension}
    end

    # returns a directory location given the gav ie. /org/glassfish/main/external/ant/
    def dir_location
      File.join(group.gsub('.', '/'), artifact)
    end

    private
    def gav_match
      /([\w\.\-]+:[\w\.\-]+:[\.\w\-]+:[\w\.\-]*:[\w\.\-]*:[\w\.\-]*)/
    end

    def err
      'Must provide gav_str in the form of "<group>:<artifact>:<version>:<repo>:<classifier>:<extension>"'
    end

  end
end
