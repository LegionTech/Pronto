class Player
  class << self
    def next_id
      @id_counter ||= 0
      @id_counter += 1
    end
  end

  attr_accessor :id, :name, :money, :position

  def initialize(attributes = {})
    @id = attributes["id"] || attributes[:id] || self.class.next_id
    @name = attributes["name"] || attributes[:name]
    @money = attributes["money"] || attributes[:money] || 16
    @position = attributes["position"] || attributes[:position] || 0
  end
end
