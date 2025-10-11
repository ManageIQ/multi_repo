module MultiRepo::Helpers
  class DryRunner
    def initialize(target, target_name = target.class.name, allowed_methods = [])
      require "colorize"

      @target = target
      @target_name = target_name
      @allowed_methods = allowed_methods.map(&:to_sym)
    end

    def method_missing(method, *args, &block)
      if @allowed_methods.include?(method)
        @target.send(method, *args, &block)
      else
        puts "** dry-run: #{@target_name}##{method}(#{args.map(&:inspect).join(", ")})".light_black
      end
    end
  end
end

