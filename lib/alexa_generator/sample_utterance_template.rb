class SampleUtteranceTemplate
  attr_reader :intent_name, :template

  def initialize(intent_name, template)
    @intent_name = intent_name
    @template = template
  end

  def referenced_slots
    template.scan( /\{([a-z]+)\}/i ).map(&:first).map(&:to_sym)
  end
end