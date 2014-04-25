module SRC
  BRANCHES = {
    master: nil,
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
    develop: nil
  }

  def self.check
    report = []
    branches.each_with_index do |branch, i|
      branches[(i + 1)..-1].each do |superset|
        unless branch.subset_of?(superset)
          report << "#{branch} should be merged into #{superset}"
        end
      end
    end

    if report.empty?
      puts 'No merges needed.'
    else
      puts report.join("\n")
    end
  end

  def self.branches
    @branches ||= BRANCHES.map do |k, v|
      if v
        sc_branch = SRC::Branch.new(k) if v
        sc_branch.latest if sc_branch.unmerged?
      else
        SRC::Git::Branch.new(k)
      end
    end.compact
  end
end
