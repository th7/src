require 'spec_helper'
require 'sc/git/branch'

def quiet
  '-q'
end

def test_file
  @test_file ||= rand(10000).to_s
end

def test_branch
  @test_branch ||= SC::Git::Branch.new('test_branch')
end

def other_branch
  @other_branch ||= SC::Git::Branch.new('other_test_branch')
end

def klass
  SC::Git::Branch
end

describe SC::Git::Branch do
  before(:all) do
    @reset_to = `git rev-parse HEAD`.chomp
    @checkout_to = `git rev-parse --abbrev-ref HEAD`.chomp
    run "touch #{test_file}"
    run "git add . -A"
    run "git commit -m 'temp commit' #{quiet}"

    run "git branch #{quiet} #{test_branch}"
  end

  after(:all) do
    run "git checkout #{@checkout_to} #{quiet}"
    run "git reset #{quiet} #{@reset_to}"
    run "rm #{test_file}"

    run "git branch -D #{quiet} #{test_branch}"
  end

  describe '.checked_out' do
    it 'returns a branch object for the currently checked out branch' do
      expect(klass.checked_out.to_s).to eq @checkout_to
    end
  end

  describe '.latest' do
    context 'a branch of this type exists' do
      before do
        run "git branch #{quiet} git_branch_latest_test-1.2.3"
        run "git branch #{quiet} git_branch_latest_test-1.2.4"
        run "git checkout git_branch_latest_test-1.2.3 #{quiet}"
      end

      after do
        run "git checkout #{@checkout_to} #{quiet}"
        run "git branch -D #{quiet} git_branch_latest_test-1.2.3"
        run "git branch -D #{quiet} git_branch_latest_test-1.2.4"
      end

      it 'returns the latest branch for this prefix type' do
        expect(klass.latest('git_branch_latest_test')).to eq 'git_branch_latest_test-1.2.4'
      end
    end

    context 'a branch of this type does not exist' do
      it 'returns nil' do
        expect(klass.latest('git_branch_latest_test')).to be_nil
      end
    end
  end

  describe '#exists?' do
    context 'the branch exists' do
      it 'returns true' do
        expect(test_branch.exists?).to eq true
      end
    end

    context 'the branch does not exist' do
      it 'returns false' do
        expect(other_branch.exists?).to eq false
      end
    end
  end

  describe '#checked_out?' do
    context 'the branch is checked out' do
      before do
        run "git checkout #{quiet} #{test_branch}"
      end

      after do
        run "git checkout - #{quiet}"
      end

      it 'returns true' do
        expect(test_branch.checked_out?).to eq true
      end
    end

    context 'the branch is not checked_out' do
      it 'returns false' do
        expect(test_branch.checked_out?).to eq false
      end
    end
  end

  describe '#subset_of?' do
    before do
      run "git branch #{quiet} #{other_branch}"
    end

    after do
      run "git branch -D #{quiet} #{other_branch}"
    end

    context 'the branch is not a subset' do
      before do
        run "git checkout #{quiet} #{other_branch}"
        run "touch subset_of_test_file"
        run 'git add .'
        run "git commit -m 'temp commit' #{quiet}"
      end

      after do
        run "git checkout - #{quiet}"
      end

      it 'returns false' do
        expect(other_branch.subset_of?(test_branch)).to eq false
      end
    end

    context 'the branch is a subset' do
      it 'returns true' do
        expect(other_branch.subset_of?(test_branch)).to eq true
      end
    end
  end

  describe '#last_commit' do
    it 'returns the commit hash of the last commit' do
      expect(test_branch.last_commit).to eq `git rev-parse #{test_branch}`.chomp
    end
  end

  describe '#checkout' do
    after do
      run "git checkout #{@checkout_to} #{quiet}"
    end

    it 'checks out the branch' do
      expect {
        test_branch.checkout
      }.to change {
        `git rev-parse --abbrev-ref HEAD`.chomp
      }.to(test_branch.to_s)
    end
  end

  describe '#merged' do
    it 'returns a list of merged branches' do
      expect([ @checkout_to, 'test_branch' ] - test_branch.merged).to eq []
    end
  end

  describe '#version' do
    it 'returns the contents of the version file' do
      expect(test_branch.version).to eq `cat #{test_branch.version_file}`.chomp
    end
  end

  describe '#branch_from' do
    after do
      run 'git branch -D from_test_branch -q'
    end

    it 'creates a new branch from self' do
      expect {
        SC::Git::Branch.new('test_branch').branch_from('from_test_branch')
      }.to change {
        system("git show-ref --verify --quiet refs/heads/from_test_branch")
      }.from(false).to(true)
      expect(`git rev-parse --abbrev-ref HEAD`.chomp).to eq @checkout_to
    end
  end

  describe '#update_version_file' do
    before do
      @reset_update_version_file_to = test_branch.last_commit
    end

    after do
      run "git checkout #{test_branch} #{quiet}"
      run "git reset --hard #{@reset_update_version_file_to} #{quiet}"
      run "git checkout #{@checkout_to} #{quiet}"
    end

    it 'updates the version file' do
      expect {
        test_branch.update_version_file('new_version')
      }.to change {
        `git show #{test_branch}:#{test_branch.version_file}`.chomp
      }.to('new_version')
    end
  end
end
