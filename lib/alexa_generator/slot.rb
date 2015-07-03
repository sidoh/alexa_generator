module AlexaGenerator
  class Slot
    module SlotType
      LITERAL = :LITERAL
      NUMBER = :NUMBER
      DATE = :DATE
      TIME = :TIME
      DURATION = :DURATION
    end

    attr_reader :name, :type

    def initialize(name, type)
      @name = name.to_sym
      @type = type
    end
  end
end