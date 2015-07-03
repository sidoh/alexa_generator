class SlotBinding
  attr_reader :slot_name, :value

  def initialize(slot_name, value)
    @slot_name = slot_name
    @value = value
  end

  def bind_to_template!(template)
    template.gsub! "{#{slot_name}}", "{#{value}|#{slot_name}}"
  end
end