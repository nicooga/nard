require 'forwardable'

class Nard::Sum
  extend Forwardable
  attr_reader :block, :range

  def initialize(range, &block)
    @range = range
    @block = block || ->(x) { x }
  end

  def value
    @value ||= range.inject(0) { |a,x| a + block[x] }
  end

  %i|+ -|.each do |operator|
    define_method operator do |other|
      # If right argument is a sum merge the blocks
      if other.kind_of?(self.class)
        # Get the range that overlaps both self and other
        range = [self, other].instance_eval do
          Range.new(*map(&:range).instance_eval do
            [min_by(&:first).first, max_by(&:last).last]
          end)
        end

        # Create a new sum that merges both blocks
        self.class.new range do |x|
          [self, other].inject 0 do |a,sum|
            sum.range === x ? a.send(operator, sum.block[x]) : a
          end
        end
      else
        self.to_i.send operator, other.to_i
      end
    end
  end

  %i|* /|.each do |operator|
    define_method operator do |other|
      self.class.new self.range do |x|
        self.block[x].send operator, other.to_i
      end
    end
  end

  %i|** == < > <= >= <=>|.each do |operator|
    define_method operator do |other|
      self.to_i.send operator, other.to_i
    end
  end

  def_delegators :value, :to_i, :to_int, :floor

  module DSL
    def sum(range, &block) Nard::Sum.new(range, &block) end
  end
end
