module Sofa
  class Layout
    attr_accessor :design, :name, :map, :reduce

    PATH = [
      './couch',
      File.join(Sofa::ROOT, '../couch')
    ]

    def initialize(name, design = nil)
      @name, @design = name, design
      @design[name] = self
      @map = @reduce = nil
      @options = {}
    end

    def load_proto_map(file_or_function, replace = {})
      return unless common_load(:proto_map, file_or_function)
      replace.each{|from, to| @proto_map.gsub!(/"\{\{#{from}\}\}"/, to) }
      @map = @proto_map
    end

    def load_proto_reduce(file_or_function, replace = {})
      return unless common_load(:proto_reduce, file_or_function)
      replace.each{|from, to| @proto_reduce.gsub!(/"\{\{#{from}\}\}"/, to) }
      @reduce = @proto_reduce
    end

    def load_map(file_or_function)
      common_load(:map, file_or_function)
    end

    def load_reduce(file_or_function)
      common_load(:reduce, file_or_function)
    end

    def common_load(root, file_or_function)
      return unless file_or_function

      if file_or_function =~ /function\(.*\)/
        function = file_or_function
      else
        filename = "#{root}/#{file_or_function}.js"

        if pathname = PATH.find{|pa| File.file?(File.join(pa, filename)) }
          function = File.read(File.join(pathname, filename))
        end
      end

      instance_variable_set("@#{root}", function) if function
    end

    def save
      @design[@name] = self.to_hash
      @design.save
    end

    def to_hash
      {:map => @map, :reduce => @reduce, :sofa_options => @options}
    end
  end
end
