require 'alexa_generator/intent'

module AlexaGenerator
  class IntentSchema
    attr_reader :intents

    def initialize(intents)
      @intents = intents
    end
  end
end