module Defacer
  class Namer
    # TODO simplify, and speed up this code
    def self.name_var_at_index(index)
      v = ''

      loop do
        mod = index % 26
        v = (mod + 97).chr + v
        index = (index / 26) - 1
        break if index < 0
      end

      v
    end
  end
end
