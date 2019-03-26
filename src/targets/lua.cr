module Bench::Targets
  class Lua
    def initialize(top_level : TopLevel)
      top_level.get_program.each do |node|
        puts node.to_lua
      end
    end
  end
end
