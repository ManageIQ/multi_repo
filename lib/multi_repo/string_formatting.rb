module MultiRepo
  module StringFormatting
    def self.enable
      ::String.prepend(self)
    end

    def red
      "\e[31m#{self}\e[0m"
    end

    def green
      "\e[32m#{self}\e[0m"
    end

    def yellow
      "\e[33m#{self}\e[0m"
    end

    def blue
      "\e[34m#{self}\e[0m"
    end

    def magenta
      "\e[35m#{self}\e[0m"
    end

    def cyan
      "\e[36m#{self}\e[0m"
    end

    def bold
      "\e[1m#{self}\e[22m"
    end
  end
end
