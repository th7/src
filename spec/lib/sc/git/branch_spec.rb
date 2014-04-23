require 'spec_helper'
require 'sc/git/branch'

describe SC::Git::Branch do
  let(:branch_name) { 'test_branch' }
  let(:test_file) { rand(10000).to_s }
  let(:branch) { SC::Git::Branch.new(branch_name) }
  let(:quiet) {  }

  before do
    run "touch #{test_file}"
    run "git add . -A #{quiet}"
    run "git commit -m 'temp commit' #{quiet}"
  end

  after do
    run "git reset --soft HEAD^ #{quiet}"
    run "rm #{test_file}"
  end

  describe '#exists?' do
    context 'the branch exists' do
      before do
        run "git branch #{quiet} #{branch_name}"
      end

      after do
        run "git branch -D #{quiet} #{branch_name}"
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
      run "git branch #{quiet} #{branch_name}"
    end

    after do
      run "git branch -D #{quiet} #{branch_name}"
    end

    context 'the branch is checked out' do
      before do
        run "git checkout #{quiet} #{branch_name}"
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
    let(:other_branch) { 'test_other_branch' }

    before do
      run "git branch #{quiet} #{branch_name}"
      run "git branch #{quiet} #{other_branch}"
    end

    after do
      run "git branch -D #{quiet} #{branch_name}"
      run "git branch -D #{quiet} #{other_branch}"
    end

    context 'the branch is a subset' do
      before do
        run "git checkout #{quiet} #{other_branch}"
        run 'touch test_file'
        run 'git add .'
        run 'git commit -m "test commit"'
      end

      after do
        run "git checkout - #{quiet}"
      end

      it 'returns true' do
        expect(branch.subset_of?(other_branch)).to eq true
      end
    end

    context 'the branch is not a subset' do
      it 'returns false' do
        expect(branch.subset_of?(other_branch)).to eq false
      end
    end
  end
end

def run(cmd)
  raise "'#{cmd}' failed" unless system cmd
end
