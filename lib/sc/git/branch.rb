module SC::Git
  class Branch
    MERGES = [
      'master',
      'hotfix',
      'release',
      'major_release',
      'develop'
    ]

    BRANCHES = {
      develop: {
        accepts: 'pull_requests',
      },
      master: {
        accepts: 'merges'
      },
      hotfix: {
        # accepts: 'pull_requests',
        cuts_from: 'master',
        prefix: 'hotfix'
      },
      release: {
        # accepts: 'pull_requests',
        cuts_from: 'develop',
        prefix: 'release'
      },
      major_release: {
        # accepts: 'pull_requests',
        cuts_from: 'develop',
        prefix: 'major-release'
      }
    }

    attr_reader :name

    class << self
      def checked_out
        new(`git rev-parse --abbrev-ref HEAD`.chomp)
      end

      def latest(prefix)
        new(`git branch | grep #{prefix}`.split(/\s+/).max)
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
      if $?.success?
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
