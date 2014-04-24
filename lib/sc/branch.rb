require 'sc/git/branch'

module SC
  class Branch
    BRANCHES = {
      hotfix: {
        branches_from: 'master',
        merges_to: 'master',
        prefix: 'hotfix',
        semantic_level: 'patch'
      },
      release: {
        branches_from: 'develop',
        merges_to: 'master',
        prefix: 'release',
        semantic_level: 'minor'
      },
      major_release: {
        branches_from: 'develop',
        merges_to: 'master',
        prefix: 'major-release',
        semantic_level: 'major'
      }
    }

    attr_reader :vc, :branches_from, :prefix, :merges_to, :semantic_level

    def initialize(type)
      opts = branches[type.to_sym]
      @vc             = SC::Git::Branch
      @branches_from  = vc.new(opts[:branches_from])
      @prefix         = opts[:prefix]
      @merges_to      = vc.new(opts[:merges_to])
      @semantic_level = opts[:semantic_level]
    end

    def cut
      if unmerged?
        puts "An unmerged #{prefix} branch exists. Checking out."
        latest.checkout
      else
        create_new
      end
    end

    def merge
      if unmerged?
        merges_to.merge(latest)
      else
        puts "No unmerged #{prefix} branch exists."
      end
    end

    def next_version
      case semantic_level
      when 'patch'
        i = 2
      when 'minor'
        i = 1
      when 'major'
        i = 0
      end

      parts = branches_from.version.split('.')
      ((i + 1)..2).each { |j| parts[j] = '0' }
      parts[i] = (parts[i].to_i + 1).to_s

      parts.join('.')
    end

    private

    def latest
      @latest ||= vc.latest(prefix)
    end

    def unmerged?
      latest && !latest.subset_of?(merges_to)
    end

    def create_new
      if branches_from == merges_to
        new_branch = branches_from.branch_from("#{prefix}-#{next_version}")
        new_branch.update_version_file(next_version)
      else
        new_branch = branches_from.branch_from("#{prefix}-#{branches_from.version}")
        branches_from.update_version_file(next_version)
      end
      new_branch.checkout
    end

    def branches
      BRANCHES
    end
  end
end
