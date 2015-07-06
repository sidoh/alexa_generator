require 'spec_helper'
require 'json'

describe AlexaGenerator::VoiceInterface do
  context 'builder' do
    it 'should build a valid voice interface' do
      iface = AlexaGenerator::VoiceInterface.build do |iface|
        iface.add_intent(:IntentOne) do |intent|
         intent.add_slot(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
            slot.add_binding('value1')
          end

          intent.add_utterance_template('test {SlotOne} test')
        end
      end

      expect(iface).to be_an_instance_of(AlexaGenerator::VoiceInterface)
      expect(iface.intent_schema).to eq(
                                         {
                                             intents: [
                                                 {
                                                     intent: :IntentOne,
                                                     slots: [
                                                         {
                                                             name: :SlotOne,
                                                             type: AlexaGenerator::Slot::SlotType::LITERAL
                                                         }
                                                     ]
                                                 }
                                             ]
                                         })
    end

    it 'should produce bound utterances' do
      iface = AlexaGenerator::VoiceInterface.build do |iface|
        iface.add_intent(:MyIntent) do |intent|
          intent.add_slot(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
            slot.add_binding('make me a sandwich')
            slot.add_binding('fix my motorcycle')
          end

          intent.add_slot(:SlotTwo, AlexaGenerator::Slot::SlotType::NUMBER) do |slot|
            slot.add_binding('one')
            slot.add_binding('two')
          end

          intent.add_slot(:SlotThree, AlexaGenerator::Slot::SlotType::TIME) do |slot|
            slot.add_binding('6 a.m.')
            slot.add_binding('noon')
          end

          intent.add_utterance_template('Alexa, please {SlotOne} {SlotTwo} at {SlotThree}')
        end
      end

      actual = iface.sample_utterances(:MyIntent)

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