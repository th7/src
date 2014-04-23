require "sc/version"

module SC
  def self.env
    @env ||= 'test'
  end

  def self.env=(new_env)
    @env = new_env
  end
  # Your code goes here...
end
