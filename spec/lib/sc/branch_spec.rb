require 'spec_helper'
require 'sc/branch'

describe SC::Branch do
  describe '#next_version' do
    before do
      branch.branches_from.stub(:version).and_return('1.2.3')
    end

    context 'a patch level change' do
      let(:branch) { SC::Branch.new('test', 'develop', 'patch') }
      it 'increments only the patch number' do
        expect(branch.next_version).to eq '1.2.4'
      end
    end

    context 'a minor level change' do
      let(:branch) { SC::Branch.new('test', 'develop', 'minor') }
      it 'increments the minor number and sets the patch to 0' do
        expect(branch.next_version).to eq '1.3.0'
      end
    end

    context 'a major level change' do
      let(:branch) { SC::Branch.new('test', 'develop', 'major') }
      it 'increments only the major number and sets others to 0' do
        expect(branch.next_version).to eq '2.0.0'
      end
    end
  end
end
