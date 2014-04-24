module SC::Git
  class Branch
    VERSION_FILE = 'version'

    attr_reader :name

    class << self
      def checked_out
        new(`git rev-parse --abbrev-ref HEAD`.chomp)
      end

      def latest(prefix)
        branch_name = `git branch`.split(/\s+/).select { |b| b =~ /\A#{prefix}/ }.max
        new(branch_name) if branch_name
      end
    end

    def initialize(name)
      @name = name.to_s
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

    def version
      `git show #{name}:#{version_file}`.chomp
    end

    def version_file
      VERSION_FILE
    end

    def update_version_file(new_version)
      checked_out do
        raise unless system("echo '#{new_version}' > #{version_file}")
        self.add(version_file)
        self.commit("version bumped to #{new_version}")
      end
    end

    def commit(msg)
      checked_out do
        raise unless system("git commit -m '#{msg}' -q")
      end
    end

    def add(filename)
      checked_out do
        raise unless system("git add #{filename}")
      end
    end

    def branch_from(new_branch)
      checked_out do
        raise unless system("git branch #{new_branch}")
      end
      self.class.new(new_branch)
    end

    def checked_out
      previous_branch = self.class.checked_out
      self.checkout
      yield
    ensure
      previous_branch.checkout
    end

    def merge(other_branch)
      checked_out do
        raise unless system("git merge --no-ff #{other_branch}")
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
