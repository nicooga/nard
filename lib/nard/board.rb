module Nard::Board
  extend Math
  extend Nard::Function::DSL
  extend Nard::Sum::DSL
  extend Nard::Sum::DSL

  singleton_class.send :alias_method, :evaluate, :instance_eval
end
