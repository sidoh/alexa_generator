module AlexaGenerator
  class Slot
    module SlotType
      LITERAL = :LITERAL
      NUMBER = :NUMBER
      DATE = :DATE
      TIME = :TIME
      DURATION = :DURATION
    end

    class Builder
      attr_reader :bindings

      def initialize(name, type)
        @name = name
        @type = type
        @bindings = []
      end

      def add_binding(value)
        add_bindings(value)
      end

      def add_bindings(*values)
        @bindings.concat(*values)
      end

      def create
        Slot.new(@name, @type)
      end
    end

    attr_reader :name, :type

    def initialize(name, type)
      @name = name.to_sym
      @type = type
    end

    def self.build(name, type, &block)
      builder = Builder.new(name, type)
      block.call(builder)
      builder
    end
  end
end