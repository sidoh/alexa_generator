require 'spec_helper'
require 'json'

describe AlexaGenerator::InteractionModel do
  context 'invalid slot bindings' do
    it 'should throw an exception' do
      expect {
        AlexaGenerator::InteractionModel.build do |iface|
          iface.add_intent(:Intent) do |intent|
            intent.add_utterance_template('{UndefinedSlot}')
          end
        end
      }.to raise_error(AlexaGenerator::AlexaSyntaxError)
    end
  end

  context 'builder' do
    it 'should build a valid voice interface' do
      iface = AlexaGenerator::InteractionModel.build do |iface|
        iface.add_intent(:IntentOne) do |intent|
         intent.add_slot(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
            slot.add_binding('value1')
          end

          intent.add_utterance_template('test {SlotOne} test')
        end
      end

      expect(iface).to be_an_instance_of(AlexaGenerator::InteractionModel)
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

    it 'should allow built in intents' do
      iface = AlexaGenerator::InteractionModel.build do |iface|
        iface.add_intent(AlexaGenerator::Intent::AmazonIntentType::CANCEL)
      end

      expect(iface).to be_an_instance_of(AlexaGenerator::InteractionModel)
      expect(iface.intent_schema).to eq(
                                         {
                                             intents: [
                                                 {
                                                     intent: :"AMAZON.CancelIntent",
                                                     slots: []
                                                 }
                                             ]
                                         })
    end

    it 'should combine custom and built in intents' do
      iface = AlexaGenerator::InteractionModel.build do |iface|
        iface.add_intent(AlexaGenerator::Intent::AmazonIntentType::CANCEL)
        iface.add_intent(:IntentOne) do |intent|
         intent.add_slot(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
            slot.add_binding('value1')
          end

          intent.add_utterance_template('test {SlotOne} test')
        end
      end

      expect(iface).to be_an_instance_of(AlexaGenerator::InteractionModel)
      expect(iface.intent_schema).to eq(
                                         {
                                             intents: [
                                                 {
                                                     intent: :"AMAZON.CancelIntent",
                                                     slots: []
                                                 },
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
      iface = AlexaGenerator::InteractionModel.build do |iface|
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

      # only the literal ones get examples
      expect(actual.count).to eq(2)
      expect(actual).to include('MyIntent Alexa, please {fix my motorcycle|SlotOne} {SlotTwo} at {SlotThree}')
      expect(actual).to include('MyIntent Alexa, please {make me a sandwich|SlotOne} {SlotTwo} at {SlotThree}')
    end
  end

  context 'with no templates' do
    intents = [ AlexaGenerator::Intent.new( :MyIntent, [] ) ]
    utterance_templates = [
        AlexaGenerator::SampleUtteranceTemplate.new( :MyIntent, 'Alexa, please do that one thing')
    ]
    slot_bindings = []

    it 'should produce utterances' do
      actual = AlexaGenerator::InteractionModel.new(intents, utterance_templates, slot_bindings).sample_utterances(:MyIntent)
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
      actual = AlexaGenerator::InteractionModel.new(intents, utterance_templates, slot_bindings).sample_utterances(:MyIntent)

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
      actual = AlexaGenerator::InteractionModel.new(intents, utterance_templates, slot_bindings).sample_utterances(:MyIntent)

      # only the literal ones get examples
      expect(actual.count).to eq(2)
      expect(actual).to include('MyIntent Alexa, please {fix my motorcycle|SlotOne} {SlotTwo} at {SlotThree}')
      expect(actual).to include('MyIntent Alexa, please {make me a sandwich|SlotOne} {SlotTwo} at {SlotThree}')
    end
  end
end