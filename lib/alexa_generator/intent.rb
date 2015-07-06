require 'alexa_generator/slot'

module AlexaGenerator
  class Intent
    attr_reader :name, :slots

    class Builder
      def initialize(name)
        @name = name
        @slots = []
      end

      def add_slot(name, type)
        @slots.push( Slot.new(name, type) )
      end

      def create
        Intent.new(name, slots)
      end
    end

    def initialize(name, slots)
      @name = name
      @slots = slots
    end
  end
end