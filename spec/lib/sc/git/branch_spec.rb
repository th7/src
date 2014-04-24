require 'spec_helper'
require 'sc/git/branch'

def run(cmd)
  raise "'#{cmd}' failed" unless system cmd
end

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
    run "git reset --soft #{quiet} #{@reset_to}"
    run "rm #{test_file}"
    run "git rm #{test_file} #{quiet}"

    run "git branch -D #{quiet} #{test_branch}"
  end

  describe '.checked_out' do
    it 'returns a branch object for the currently checked out branch' do
      expect(klass.checked_out.to_s).to eq @checkout_to
    end
  end

  describe '.latest' do
    before do
      run "git branch #{quiet} release-1.2.3"
      run "git branch #{quiet} release-1.2.4"
      run "git checkout release-1.2.3 #{quiet}"
    end

    after do
      run "git checkout #{@checkout_to} #{quiet}"
      run "git branch -D #{quiet} release-1.2.3"
      run "git branch -D #{quiet} release-1.2.4"
    end

    it 'returns the latest branch for this prefix type' do
      expect(klass.latest('release').to_s).to eq 'release-1.2.4'
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
end
