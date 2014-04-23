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
  'test_branch'
end

def other_branch
  'other_test_branch'
end

describe SC::Git::Branch do
  let(:branch) { SC::Git::Branch.new(test_branch) }

  before(:all) do
    @reset_to = `git rev-parse HEAD`.chomp
    run "touch #{test_file}"
    run "git add . -A"
    run "git commit -m 'temp commit' #{quiet}"
  end

  after(:all) do
    run "git reset --soft #{quiet} #{@reset_to}"
    run "rm #{test_file}"
    run "git rm #{test_file} #{quiet}"
  end

  describe '#exists?' do
    context 'the branch exists' do
      before do
        run "git branch #{quiet} #{test_branch}"
      end

      after do
        run "git branch -D #{quiet} #{test_branch}"
      end

      it 'returns true' do
        expect(branch.exists?).to eq true
      end
    end

    context 'the branch does not exist' do
      it 'returns false' do
        expect(branch.exists?).to eq false
      end
    end
  end

  describe '#checked_out?' do
    before do
      run "git branch #{quiet} #{test_branch}"
    end

    after do
      run "git branch -D #{quiet} #{test_branch}"
    end

    context 'the branch is checked out' do
      before do
        run "git checkout #{quiet} #{test_branch}"
      end

      after do
        run "git checkout - #{quiet}"
      end

      it 'returns true' do
        expect(branch.checked_out?).to eq true
      end
    end

    context 'the branch is not checked_out' do
      it 'returns false' do
        expect(branch.checked_out?).to eq false
      end
    end
  end

  describe '#subset_of?' do
    before do
      run "git branch #{quiet} #{test_branch}"
      run "git branch #{quiet} #{other_branch}"
    end

    after do
      run "git branch -D #{quiet} #{test_branch}"
      run "git branch -D #{quiet} #{other_branch}"
    end

    context 'the branch is not a subset' do
      before do
        run "git checkout #{quiet} #{test_branch}"
        run 'touch test_file'
        run 'git add .'
        run "git commit -m 'temp commit' #{quiet}"
      end

      after do
        run "git checkout - #{quiet}"
      end

      it 'returns false' do
        expect(branch.subset_of?(other_branch)).to eq false
      end
    end

    context 'the branch is a subset' do
      it 'returns true' do
        expect(branch.subset_of?(other_branch)).to eq true
      end
    end
  end
end
