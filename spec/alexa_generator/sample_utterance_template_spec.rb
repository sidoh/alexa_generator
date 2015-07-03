require 'spec_helper'

describe AlexaGenerator::SampleUtteranceTemplate do
  it 'should parse slots out of templates' do
    template = AlexaGenerator::SampleUtteranceTemplate.new 'MyIntent', 'Intent, {SlotOne} and {SlotTwo}'

    expect(template.referenced_slots).to eq([:SlotOne, :SlotTwo])
  end

  it 'should work with no slots' do
    template = AlexaGenerator::SampleUtteranceTemplate.new 'MyIntent', 'Intent, do that thing'

    expect(template.referenced_slots).to eq([])
  end

  it 'should not detect bound slots' do
    template = AlexaGenerator::SampleUtteranceTemplate.new 'MyIntent', 'Intent, do {that|Thing}'

    expect(template.referenced_slots).to eq([])
  end
end