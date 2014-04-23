module SC::Git
  class Branch
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def exists?
      system("git show-ref --verify --quiet refs/heads/'#{name}'")
    end

    def checked_out?
      `git rev-parse --abbrev-ref HEAD`.chomp == name
    end

    def subset_of?(other_branch)
      `git rev-list #{other_branch}..#{name}`.chomp.length == 0
    end

    def last_commit
      `git rev-parse #{name}`.chomp
    end

    def to_s
      name
    end
  end
end
