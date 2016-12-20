require 'spec_helper'

describe AlexaGenerator::Slot do
  context 'builder' do
    it 'should return an instance of a builder' do
      slot = AlexaGenerator::Intent.build(:IntentOne) { |x| }

      expect(slot).to be_an_instance_of(AlexaGenerator::Intent::Builder)
    end

    it 'should add slot bindings' do
      intent = AlexaGenerator::Intent.build(:IntentOne) do |intent|
        intent.add_slot(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
          slot.add_bindings('a', 'b', 'c')
        end
      end

      expect(intent.bindings).to be_an_instance_of(Array)
      expect(intent.bindings.map(&:value)).to eq(['a', 'b', 'c'])
    end

    it 'should create an intent when create is called' do
      builder = AlexaGenerator::Intent.build(:IntentOne) do |intent|
        intent.add_slot(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
          slot.add_bindings('a', 'b', 'c')
        end
      end

      intent = builder.create

      expect(intent.name).to eq(:IntentOne)

      expect(intent.slots.count).to eq(1)
      expect(intent.slots.first.name).to eq(:SlotOne)
    end
    
    it 'should whine when trying to add a slot to an Amazon intent' do
      AlexaGenerator::Intent.build(AlexaGenerator::Intent::AmazonIntentType::CANCEL) do |intent|
        expect {
          intent.add_slot(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL)
        }.to raise_error(AlexaGenerator::InvalidIntentError)
      end
    end
  end
end
