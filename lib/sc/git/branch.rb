module SC::Git
  class Branch
    attr_reader :name

    class << self
      def checked_out
        new(`git rev-parse --abbrev-ref HEAD`.chomp)
      end
    end

    def initialize(name)
      @name = name
    end

    def exists?
      system("git show-ref --verify --quiet refs/heads/'#{name}'")
    end

    def checkout
      msg = `git checkout #{name} -q`
      raise msg unless $?.success?
    end

    def checked_out?
      self.class.checked_out == self
    end

    def subset_of?(other_branch)
      `git rev-list #{other_branch}..#{name}`.chomp.length == 0
    end

    def last_commit
      hash = `git rev-parse #{name}`.chomp
      if hash =~ /\A[0-9a-f]{40}\z/
        hash
      else
        raise hash
      end
    end

    def to_s
      name
    end

    def ==(other)
      name == other.to_s
    end
  end
end
