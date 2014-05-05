class Nard::Function
  extend Forwardable
  attr_reader :block, :cache

  def initialize(&block) @block = block end
  def [](x) (@cache ||= {})[x] ||= block.call(x) end

  module DSL
    def function(&block) Nard::Function.new(&block) end
  end
end
