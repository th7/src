module SC
  def self.env
    @env ||= 'test'
  end

  def self.env=(new_env)
    @env = new_env
  end

  def self.exec(cmd)
    if env == 'test'
      commands << cmd
    else
      `#{cmd}`
    end
  end

  def self.commands
    @commands ||= []
  end
end
