require 'spec_helper'
require 'src/git'

describe SRC::Git do
  describe '.fetch' do
    it 'is too damn hard to spec and is merely checked for existence' do
      expect(SRC::Git.respond_to?(:fetch)).to eq true
    end
  end
end
