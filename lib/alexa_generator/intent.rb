require 'alexa_generator/slot'
require 'alexa_generator/sample_utterance_template'

module AlexaGenerator
  class Intent

    module AmazonIntentType
      VALUES = [
        CANCEL =      :"AMAZON.CancelIntent",
        HELP =        :"AMAZON.HelpIntent",
        LOOP_OFF =    :"AMAZON.LoopOffIntent",
        LOOP_ON  =    :"AMAZON.LoopOnIntent",
        NEXT =        :"AMAZON.NextIntent",
        NO =          :"AMAZON.NoIntent",
        PAUSE =       :"AMAZON.PauseIntent",
        PREVIOUS =    :"AMAZON.PreviousIntent",
        REPEAT =      :"AMAZON.RepeatIntent",
        RESUME =      :"AMAZON.ResumeIntent",
        SHUFFLE_OFF = :"AMAZON.ShuffleOffIntent",
        SHUFFLE_ON =  :"AMAZON.ShuffleOnIntent",
        START_OVER =  :"AMAZON.StartOverIntent",
        STOP =        :"AMAZON.StopIntent",
        YES =         :"AMAZON.YesIntent"
      ]
      
      def self.amazon_intent?(val)
        VALUES.include?(val.to_sym)
      end
    end

    attr_reader :name, :slots

    class Builder
      attr_reader :bindings, :utterance_templates

      def initialize(name)
        @name = name
        @slots = []
        @bindings = []
        @utterance_templates = []
      end

      def add_slot(name, type, &block)
        if AmazonIntentType.amazon_intent?(@name)
          raise AlexaGenerator::InvalidIntentError,
            "Amazon intents don't support slots. Tried to add a slot to intent of type: #{type}"
        end
        
        builder = Slot.build(name, type, &block)

        slot_bindings = builder.bindings.map { |x| SlotBinding.new(name, x) }
        @bindings.concat(slot_bindings)

        @slots.push(builder.create)
      end

      def add_utterance_template(template)
        add_utterance_templates(template)
      end

      def add_utterance_templates(*templates)
        templates.each { |x| @utterance_templates.push(SampleUtteranceTemplate.new(@name, x)) }
      end

      def create
        Intent.new(@name, @slots)
      end
    end

    def initialize(name, slots)
      @name = name
      @slots = slots
    end
    
    def amazon_intent?
      AmazonIntentType.amazon_intent?(@name)
    end

    def self.build(name, &block)
      builder = Builder.new(name)
      block.call(builder) if block
      builder
    end
  end
end