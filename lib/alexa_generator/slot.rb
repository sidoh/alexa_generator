module AlexaGenerator
  class Slot
    module SlotType
      LITERAL = :"AMAZON.LITERAL"
      NUMBER = :"AMAZON.NUMBER"
      DATE = :"AMAZON.DATE"
      TIME = :"AMAZON.TIME"
      DURATION = :"AMAZON.DURATION"
      
      def self.literal?(value)
        [:LITERAL, LITERAL].include?(value.to_sym)
      end
      
      def self.custom?(value)
        !literal?(value) && !value.to_s.start_with?('AMAZON.')
      end
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
        @bindings.concat(values)
      end

      def create
        Slot.new(@name, @type, @bindings)
      end
    end

    attr_reader :name, :type, :bindings

    def initialize(name, type, bindings)
      @name = name.to_sym
      @type = type
      @bindings = bindings
    end

    def self.build(name, type, &block)
      builder = Builder.new(name, type)
      block.call(builder) if block
      builder
    end
  end
end