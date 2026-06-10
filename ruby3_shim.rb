# Ruby 3 compatibility shim for legacy gems (like Bundler 1.x) that call removed taint methods
class Object
  unless respond_to?(:untaint)
    def untaint; self; end
  end
  unless respond_to?(:taint)
    def taint; self; end
  end
  unless respond_to?(:trust)
    def trust; self; end
  end
end
