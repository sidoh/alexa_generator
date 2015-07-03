require 'spec_helper'

describe AlexaGenerator::SampleUtteranceTemplate do
  it 'should parse slots out of templates' do
    template = SampleUtteranceTemplate.new 'MyIntent', 'Intent, {SlotOne} and {SlotTwo}'

    expect(template.referenced_slots).to eq([:SlotOne, :SlotTwo])
  end
end