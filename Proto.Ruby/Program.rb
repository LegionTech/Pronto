require "json"
require_relative "Player"
require_relative "Property"

def load_json_file(file_name)
  data = JSON.parse(File.read(file_name))
  data.map do |item|
    if item.key?("name") && item["name"] == "GO"
      # For GO tile
      Property.new(
        "id" => item["id"] || nil,
        "name" => item["name"],
        "price" => item["price"] || 0,
        "colour" => item["colour"] || nil,
        "type" => item["type"] || "go",
        "rent" => item["rent"] || 1,
        "owner_id" => item["owner_id"] || 0
      )
    else
      Property.new(item)
    end
  end
end

def run_game(players, properties, rolls)
  boundary = properties.length
  player_size = players.length
  is_run = true
  x = 0

  while is_run && x < rolls.length
    player = players[x % player_size]
    dice = rolls[x]

    roll_dice(players, player, dice, boundary)

    property = properties[player.position]

    if player.position.positive?
      do_property(players, properties, player, property)
    end

    x += 1
  end

  puts "Game Over! #{is_run}, #{x} : #{rolls.length}"
end

def do_property(players, properties, player, property)
  if property.owner_id == 0
    if player.money >= property.price
      purchase_property(players, properties, player.id, property.id)
    else
      game_over(players, player.name)
    end
  else
    if property.owner_id != player.id
      if player.money >= property.rent
        pay_rent(players, properties, player.id, property.id)
      else
        game_over(players, player.name)
      end
    end
  end
end

def purchase_property(players, properties, player_id, property_id)
  player = players.find { |p| p.id == player_id }
  property = properties[property_id]

  player.money -= property.price
  property.owner_id = player.id

  puts "#{player.name} purchased #{property.name} for $#{property.price}. Remaining: $#{player.money}"

  check_property_owner(properties, property.color, player.id, player.name)
end

def check_property_owner(properties, color, player_id, player_name)
  is_color_same_owner = properties.select { |p| p.color == color }.all? { |p| p.owner_id == player_id }

  if is_color_same_owner
    puts "#{player_name} owns all #{color} properties. Rent is doubled!"

    properties.each do |prop|
      if prop.color == color && prop.owner_id == player_id
        prop.rent *= 2
        puts "#{prop.name} rent is increased to #{prop.rent}"
      end
    end
  end
end

def roll_dice(players, player, dice, boundary)
  position_current = player.position
  position_new = position_current + dice

  if position_new >= boundary
    position_new -= boundary
    player.money += 1
    puts "#{player.name} passed GO and collected $1."
  end

  player.position = position_new

  puts "#{player.name} rolled #{dice} and moved from #{position_current} to #{position_new}. Current money: $#{player.money}"
end

def pay_rent(players, properties, player_id, property_id)
  property = properties[property_id]
  owner = players.find { |p| p.id == property.owner_id }
  player = players.find { |p| p.id == player_id }

  owner.money += property.rent
  player.money -= property.rent

  puts "#{player.name} paid #{property.name} $#{property.rent} to #{owner.name}. #{player.name}: $#{player.money}. Owner #{owner.name}: $#{owner.money}"

  if player.money.negative?
    game_over(players, player.name)
  end
end

def game_over(players, player_name)
  puts "#{player_name} is bankrupt!"

  winner = players.max_by(&:money)
  puts "Winner is #{winner.name} with #{winner.money} money"

  players.each do |player|
    place = player.position
    property = nil
    puts "#{player.name} has $#{player.money} at #{place}"
  end
end

players = JSON.parse(File.read("players.json")).map { |p| Player.new(p) }
properties = JSON.parse(File.read("board.json")).map { |p| Property.new(p) }
rolls_1 = JSON.parse(File.read("rolls_1.json"))

puts "Start the game..."

run_game(players, properties, rolls_1)

puts "Game Complete!"