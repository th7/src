require 'spec_helper'
require 'sc/git'

describe SC::Git do
  describe '.fetch' do
    it 'is too damn hard to spec and is merely checked for existence' do
      expect(SC::Git.respond_to?(:fetch)).to eq true
    end
  end
end
