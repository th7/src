require 'spec_helper'
require 'src/cli'

describe SRC::CLI do
  let(:cli) { SRC::CLI.new }
  let(:dub) { double }

  describe '#run' do
    before do
      cli.stub(:argv).and_return(['function', 'more', 'base', 'args'])
    end

    it 'calls a function corresponding to the first arg with remaining base args' do
      expect(cli).to receive(:function).with('more', 'base', 'args')
      cli.run
    end
  end

  describe '#cut' do
    before do
      cli.stub(:options).and_return(base_args: [ 'cut', 'type' ])
    end

    it 'passes args and options to a new instance of SRC::Cutter and calls cut' do
      expect(SRC::Branch).to receive(:new).with('type').and_return(dub)
      expect(dub).to receive(:cut)
      cli.run
    end
  end

  describe '#options' do
    context 'argv has one base arg' do
      before do
        cli.stub(:argv).and_return(['arg'])
      end

      it 'puts { :base_args => arg } into the options hash' do
        expect(cli.options[:base_args]).to eq 'arg'
      end
    end

    context 'argv has multiple base args' do
      before do
        cli.stub(:argv).and_return(['arg1', 'arg2'])
      end

      it 'puts { :base_args => [ arg1, arg2 ] } into the options hash' do
        expect(cli.options[:base_args]).to eq [ 'arg1', 'arg2' ]
      end
    end

    context 'argv has an option with no following value' do
      before do
        cli.stub(:argv).and_return(['-option'])
      end

      it 'puts { :option => nil } into the options hash' do
        expect(cli.options.has_key?(:option)).to be_true
        expect(cli.options[:option]).to eq nil
      end
    end

    context 'argv has an option with one following value' do
      before do
        cli.stub(:argv).and_return(['-option', 'value'])
      end

      it 'puts { :option => "value" } into the options hash' do
        expect(cli.options[:option]).to eq('value')
      end
    end

    context 'argv has an option with several following values' do
      before do
        cli.stub(:argv).and_return(['-option', 'value1', 'value2', 'value3'])
      end

      it 'puts { :option => ["value1", "value2", "value3"] } into the options hash' do
        expect(cli.options[:option]).to eq(['value1', 'value2', 'value3'])
      end
    end

    context 'argv has complex options and values with several following values' do
      before do
        cli.stub(:argv).and_return(['-option1', '-option2', 'value2-1', '-option3', 'value3-1', 'value3-2', 'value3-3'])
      end

      it 'builds the options hash' do
        expect(cli.options[:option1]).to eq(nil)
        expect(cli.options[:option2]).to eq('value2-1')
        expect(cli.options[:option3]).to eq(['value3-1', 'value3-2', 'value3-3'])
      end
    end
  end
end
