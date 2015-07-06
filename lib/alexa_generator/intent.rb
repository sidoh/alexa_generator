require 'alexa_generator/slot'

module AlexaGenerator
  class Intent
    attr_reader :name, :slots

    class Builder
      attr_reader :bindings

      def initialize(name)
        @name = name
        @slots = []
        @bindings = {}
      end

      def add_slot(name, type, &block)
        builder = Slot.build(name, type, &block)

        @bindings[name] ||= []
        @bindings[name].concat(builder.bindings)

        @slots.push(builder.create)
      end

      def create
        Intent.new(@name, @slots)
      end
    end

    def initialize(name, slots)
      @name = name
      @slots = slots
    end

    def self.build(name, &block)
      builder = Builder.new(name)
      block.call(builder)
      builder
    end
  end
end