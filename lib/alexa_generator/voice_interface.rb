require 'set'

class VoiceInterface
  attr_reader :intents

  def initialize(intents, utterance_templates, slot_bindings)
    @intents = Hash[ intents.map {|x| [x.name, x]} ]

    @utterance_templates = utterance_templates.group_by { |x| x.intent_name }
    @slot_bindings = slot_bindings.group_by { |x| x.slot_name }
  end

  def sample_utterances(intent_name)
    templates = @utterance_templates[intent_name]
    utterances = Set.new

    templates.each do |template|
      # Consider only the slots that are referenced in this template
      relevant_slots = template.referenced_slots

      # Compute all possible value bindings for the relevant slots
      slot_values = relevant_slots.
          # Extract value bindings for each slot
          map { |slot| @slot_bindings[slot] }

      if slot_values.any?
        slot_value_combinations = slot_values.first

        if slot_values.count > 1
          slot_value_combinations = slot_value_combinations.product(slot_values[1..-1])
        end

        slot_value_combinations.each do |value_binding|
          raw_template = template.template.dup

          value_binding.each do |binding|
            binding.bind_to_template!( raw_template )
          end

          utterances.add( raw_template )
        end
      # If there are no slot values, then just stuff the untouched template into utterances.
      else
        utterances.add( template.template )
      end
    end

    utterances.sort.map do |utterance|
      "#{intent_name} #{utterance}"
    end
  end
end