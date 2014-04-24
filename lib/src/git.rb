module SRC::Git
  def self.fetch
    raise 'fetch failed' unless system('git fetch -q')
  end
end
