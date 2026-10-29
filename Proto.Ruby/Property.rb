require_relative "PropertyEnums"

class Property
  class << self
    def next_id
      @id_counter ||= 0
      @id_counter += 1
    end
  end

  attr_accessor :id, :name, :price, :color, :type, :rent, :owner_id

  def initialize(attributes = {})
    @id = attributes["id"] || attributes[:id] || self.class.next_id
    @name = attributes["name"] || attributes[:name]
    @price = attributes["price"] || attributes[:price] || 0
    @color = normalize_color(attributes["colour"] || attributes[:colour])
    @type = normalize_type(attributes["type"] || attributes[:type])
    @rent = attributes["rent"] || attributes[:rent] || 1
    @owner_id = attributes["owner_id"] || attributes[:owner_id] || 0
  end

  private

  def normalize_color(value)
    case value.to_s.downcase
    when "red" then PropertyColor::RED
    when "green" then PropertyColor::GREEN
    when "blue" then PropertyColor::BLUE
    when "brown" then PropertyColor::BROWN
    when nil, "" then nil
    else
      raise ArgumentError, "Invalid color value: #{value.inspect}"
    end
  end

  def normalize_type(value)
    case value.to_s.downcase
    when "property" then PropertyType::PROPERTY
    when "go" then PropertyType::GO
    else
      raise ArgumentError, "Invalid type value: #{value.inspect}"
    end
  end
end