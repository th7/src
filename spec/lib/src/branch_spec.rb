require 'spec_helper'
require 'src/branch'

describe SRC::Branch do
  describe '#next_version' do
    let(:branch) { SRC::Branch.new('testing #next_version') }

    before do
      SRC::Branch.any_instance.stub(:branches).and_return(double(:'[]' => {}))
      branch.stub(:branches_from).and_return(double(version: '1.2.3'))
    end

    context 'a patch level change' do
      before do
        branch.stub(:semantic_level).and_return('patch')
      end

      it 'increments only the patch number' do
        expect(branch.next_version).to eq '1.2.4'
      end
    end

    context 'a minor level change' do
      before do
        branch.stub(:semantic_level).and_return('minor')
      end

      it 'increments the minor number and sets the patch to 0' do
        expect(branch.next_version).to eq '1.3.0'
      end
    end

    context 'a major level change' do
      before do
        branch.stub(:semantic_level).and_return('major')
      end

      it 'increments only the major number and sets others to 0' do
        expect(branch.next_version).to eq '2.0.0'
      end
    end
  end
end
