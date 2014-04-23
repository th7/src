require 'spec_helper'
require 'sc/cli'

describe SC::CLI do
  let(:cli) { SC::CLI.new }

  describe '#run' do
    it 'returns a value' do
      expect(cli.run).to eq 'stubbed'
    end
  end
end
