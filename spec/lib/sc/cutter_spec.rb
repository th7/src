require 'spec_helper'

describe SC::Cutter do
  context 'type is patch, cuts from master' do
    let(:cutter) { SC::Cutter.new('patch') }
    before do
      cutter.stub(:cut_from_hash).and_return(patch: :master)
    end

    describe '#cut' do
      it 'is stubbed' do
        expect(cutter).to receive(:old_version).and_return('0.0.1')

        expect {
          cutter.cut
        }.to change {
          SC.commands
        }.from([]).to(
          [
            "git checkout master",
            "git checkout -b patch-0.0.2",
            "echo '0.0.2' > version",
            "git add version",
            "git commit -m 'bumped version to 0.0.2'"
          ]
        )
      end
    end
  end
end
