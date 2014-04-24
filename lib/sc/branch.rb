require 'sc'
require 'sc/git/branch'

module SC
  class Branch
    BRANCHES = {
      develop: {
        accepts: 'pull_requests'
      },
      master: {
        accepts: 'merges'
      },
      hotfix: {
        # accepts: 'pull_requests',
        branches_from: 'master',
        prefix: 'hotfix',
        semantic_level: 'patch'
      },
      release: {
        # accepts: 'pull_requests',
        branches_from: 'develop',
        prefix: 'release',
        semantic_level: 'minor'
      },
      major_release: {
        # accepts: 'pull_requests',
        branches_from: 'develop',
        prefix: 'major-release',
        semantic_level: 'major'
      }
    }

    attr_reader :vc, :branches_from, :prefix, :merges_to, :semantic_level

    def initialize(prefix, branches_from, semantic_level, merges_to='master')
      @vc             = SC::Git::Branch
      @branches_from  = vc.new(branches_from)
      @prefix         = prefix
      @merges_to      = vc.new(merges_to)
      @semantic_level = semantic_level
    end

    def cut
      if unmerged?
        latest.checkout
      else
        create_new
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
        # cut branch
        # increment version on new branch
      else
        # cut branch
        # increment version on original branch
      end
    end


    def branches
      BRANCHES
    end
  end
end

module SC; class Branch::Error < SC::Error; end; end
