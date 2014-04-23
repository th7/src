module SC
  class Cutter
    CUT_FROM_HASH = {
      patch: 'master',
      minor: 'develop',
      major: 'develop'
    }

    PREFIXES = {
      patch: 'patch',
      minor: 'minor',
      major: 'major'
    }

    CUT_TYPE = {
      patch: :fix,
      minor: :release,
      major: :release
    }

    VERSION_FILE = 'version'

    def initialize(type, opts={})
      @options = opts
      @type = type.to_sym
    end

    def cut
      case cut_type[type]
      when :fix
        cut_fix
      when :release
        cut_release
      end
    end

    def cut_fix
      if branch_exists?(new_branch)
        puts "Branch '#{new_branch}' already exists."
        SC.exec "git checkout #{new_branch}"
      else
        SC.exec "git checkout #{cut_from}" unless on_branch?(cut_from)
        SC.exec "git checkout -b #{new_branch}"
        SC.exec "echo '#{new_version}' > #{version_file}"
        SC.exec "git add #{version_file}"
        SC.exec "git commit -m 'bumped version to #{new_version}'"
      end
    end

    def cut_release
      if branch_exists?(new_branch)
        puts "Branch '#{new_branch}' already exists."
        SC.exec "git checkout #{new_branch}"
      else
        SC.exec "git checkout #{cut_from}" unless on_branch?(cut_from)
        SC.exec "git branch #{new_branch}"
        SC.exec "echo '#{new_version}' > #{version_file}"
        SC.exec "git add #{version_file}"
        SC.exec "git commit -m 'bumped version to #{new_version}'"
        SC.exec "git checkout #{new_branch}"
      end
    end

    private

    def cut_type
      CUT_TYPE
    end

    def type
      @type
    end

    def cut_from
      cut_from_hash[type]
    end

    def cut_from_hash
      CUT_FROM_HASH
    end

    def old_version
      return @old_version if @old_version
      system("git checkout #{cut_from}") unless on_branch?(cut_from)
      @old_version ||= `cat #{version_file}`.chomp
    end

    def on_branch?(branch)
      `git rev-parse --abbrev-ref HEAD`.chomp == branch
    end

    def branch_exists?(branch)
      system("git show-ref --verify --quiet refs/heads/'#{branch}'")
    end

    def subset?(subset_branch, superset_branch)
      `git rev-list #{subset_branch}..#{superset_branch}`.chomp.length > 0
    end

    def version_file
      VERSION_FILE
    end

    def new_branch
      @new_branch ||= "#{prefix}-#{new_version}"
    end

    def prefix
      prefixes[type]
    end

    def existing_branch
      @existing_branch ||= "#{prefix}-#{current_version}"
    end

    def prefixes
      PREFIXES
    end

    def new_version
      return @new_version if @new_version

      case type
      when :patch
        i = 2
      when :minor
        i = 1
      when :major
        i = 0
      end

      parts = old_version.split('.')
      ((i + 1)..2).each { |j| parts[j] = '0' }
      parts[i] = (parts[i].to_i + 1).to_s

      @new_version = parts.join('.')
    end
  end
end
