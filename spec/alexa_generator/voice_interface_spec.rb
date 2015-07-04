require 'spec_helper'

describe AlexaGenerator::VoiceInterface do
  context 'with no templates' do
    intents = [ AlexaGenerator::Intent.new( :MyIntent, [] ) ]
    utterance_templates = [
        AlexaGenerator::SampleUtteranceTemplate.new( :MyIntent, 'Alexa, please do that one thing')
    ]
    slot_bindings = []

    it 'should produce utterances' do
      actual = AlexaGenerator::VoiceInterface.new(intents, utterance_templates, slot_bindings).sample_utterances(:MyIntent)
      expected = [ "#{utterance_templates.first.intent_name} #{utterance_templates.first.template}" ]

      expect(actual).to eq(expected)
    end
  end

  context 'with a single template' do
    intents = [
        AlexaGenerator::Intent.new(
            :MyIntent, [ AlexaGenerator::Slot.new(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) ]
        )
    ]
    utterance_templates = [
        AlexaGenerator::SampleUtteranceTemplate.new( :MyIntent, 'Alexa, please {SlotOne}')
    ]
    slot_bindings = [
        AlexaGenerator::SlotBinding.new( :SlotOne, 'make me a sandwich' ),
        AlexaGenerator::SlotBinding.new( :SlotOne, 'fix my motorcycle' )
    ]

    it 'should produce bound utterances' do
      actual = AlexaGenerator::VoiceInterface.new(intents, utterance_templates, slot_bindings).sample_utterances(:MyIntent)

      expect(actual.count).to eq(slot_bindings.count)
      expect(actual).to include('MyIntent Alexa, please {make me a sandwich|SlotOne}')
      expect(actual).to include('MyIntent Alexa, please {fix my motorcycle|SlotOne}')
    end
  end

  context 'with multiple templates' do
    intents = [
        AlexaGenerator::Intent.new(
            :MyIntent, [
                         AlexaGenerator::Slot.new(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL),
                         AlexaGenerator::Slot.new(:SlotTwo, AlexaGenerator::Slot::SlotType::NUMBER),
                         AlexaGenerator::Slot.new(:SlotThree, AlexaGenerator::Slot::SlotType::TIME),
                     ],
        )
    ]
    utterance_templates = [
        AlexaGenerator::SampleUtteranceTemplate.new( :MyIntent, 'Alexa, please {SlotOne} {SlotTwo} at {SlotThree}')
    ]
    slot_bindings = [
        AlexaGenerator::SlotBinding.new( :SlotOne, 'make me a sandwich' ),
        AlexaGenerator::SlotBinding.new( :SlotOne, 'fix my motorcycle' ),

        AlexaGenerator::SlotBinding.new( :SlotTwo, 'one' ),
        AlexaGenerator::SlotBinding.new( :SlotTwo, 'two' ),

        AlexaGenerator::SlotBinding.new( :SlotThree, '6 a.m.' ),
        AlexaGenerator::SlotBinding.new( :SlotThree, 'noon' ),
    ]

    it 'should produce bound utterances' do
      actual = AlexaGenerator::VoiceInterface.new(intents, utterance_templates, slot_bindings).sample_utterances(:MyIntent)

      expect(actual.count).to eq(8)
      expect(actual).to include('MyIntent Alexa, please {fix my motorcycle|SlotOne} {one|SlotTwo} at {noon|SlotThree}')
      expect(actual).to include('MyIntent Alexa, please {fix my motorcycle|SlotOne} {two|SlotTwo} at {noon|SlotThree}')
      expect(actual).to include('MyIntent Alexa, please {make me a sandwich|SlotOne} {one|SlotTwo} at {noon|SlotThree}')
      expect(actual).to include('MyIntent Alexa, please {make me a sandwich|SlotOne} {two|SlotTwo} at {noon|SlotThree}')
      expect(actual).to include('MyIntent Alexa, please {fix my motorcycle|SlotOne} {one|SlotTwo} at {6 a.m.|SlotThree}')
      expect(actual).to include('MyIntent Alexa, please {fix my motorcycle|SlotOne} {two|SlotTwo} at {6 a.m.|SlotThree}')
      expect(actual).to include('MyIntent Alexa, please {make me a sandwich|SlotOne} {one|SlotTwo} at {6 a.m.|SlotThree}')
      expect(actual).to include('MyIntent Alexa, please {make me a sandwich|SlotOne} {two|SlotTwo} at {6 a.m.|SlotThree}')
    end
  end
end