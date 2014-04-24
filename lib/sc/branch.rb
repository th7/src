require 'sc'
require 'sc/git/branch'

module SC
  class Branch
    attr_reader :vc, :branches_from, :prefix, :merges_to, :semantic_level

    def initialize(type)
      opts            = branches[type.to_sym] || {}
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
        if merges_to.subset_of?(latest)
          merges_to.merge(latest)
        else
          puts "You must first merge #{merges_to} into #{latest}"
        end
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

    def latest
      @latest ||= vc.latest(prefix)
    end

    def unmerged?
      latest && !latest.subset_of?(merges_to)
    end

    private

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
      SC::BRANCHES
    end
  end
end
