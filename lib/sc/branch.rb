require 'sc'

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

    attr_reader :vc, :cuts_from, :prefix, :merges_to

    def initialize(prefix, cuts_from, merges_to='master')
      @vc        = SC::Git::Branch
      @cuts_from = vc.new(cuts_from)
      @prefix    = prefix
      @merges_to = vc.new(merges_to)
    end

    def cut
      if unmerged?
        latest.checkout
      else
        create_new
      end
    end

    private

    def latest
      @latest ||= vc.latest(prefix)
    end

    def unmerged?
      latest && !latest.subset_of?(merges_to)
    end

    def create_new
      if cuts_from == merges_to
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
