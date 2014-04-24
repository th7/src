require 'sc/branch'

module SC
  class CLI
    def run
      public_send(*options[:base_args])
    end

    def cut(*args)
      SC::Branch.new(SC::Branch::BRANCHES[args[0].to_sym]).cut
    end

    def options
      @options ||= parse
    end

    def parse
      key = :base_args
      argv.inject({}) do |args, val|
        if val[0] == '-'
          key = val.gsub('-', '').to_sym
          args[key] ||= nil
        elsif args[key]
          args[key] = [args[key]] unless args[key].kind_of? Array
          args[key] << val
        else
          args[key] = val
        end
        args
      end
    end

    private

    def argv
      ARGV
    end
  end
end
