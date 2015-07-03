module AlexaGenerator
  class Intent
    attr_reader :name, :slots

    def initialize(name, slots)
      @name = name
      @slots = slots
    end
  end
end