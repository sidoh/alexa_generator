require 'spec_helper'

describe AlexaGenerator::Slot do
  context 'builder' do
    it 'should return an instance of a builder' do
      slot = AlexaGenerator::Slot.build(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) { |x| }

      expect(slot).to be_an_instance_of(AlexaGenerator::Slot::Builder)
    end

    it 'should add slot bindings' do
      slot = AlexaGenerator::Slot.build(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
        slot.add_bindings('a', 'b', 'c')
      end

      expect(slot.bindings).to eq(['a', 'b', 'c'])
    end

    it 'should create a slot when create is called' do
      builder = AlexaGenerator::Slot.build(:SlotOne, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
        slot.add_bindings('a', 'b', 'c')
      end

      slot = builder.create

      expect(slot.name).to eq(:SlotOne)
      expect(slot.type).to eq(AlexaGenerator::Slot::SlotType::LITERAL)
    end
  end
end