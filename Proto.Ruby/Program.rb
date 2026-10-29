require "json"
require_relative "Player"
require_relative "Property"

# Global shared lists
$players = []
$properties = []

def run_game(rolls)
  boundary = $properties.length
  player_size = $players.length
  rolls_size = rolls.length
  # puts "Game Start! Players: #{player_size}, Properties: #{$properties.length}, Rolls: #{rolls.length}"

  is_run = true
  x = 0

  while is_run && x < rolls_size
    player = $players[x % player_size]
    dice = rolls[x]
    playerId = player.id

    roll_dice(playerId, dice)
    
    property = $properties.find { |p| p.id == player.position }

    # puts "#{player.name} landed on #{property.name}: #{property.type}"

    if(property.type == PropertyType::PROPERTY)
      do_property(playerId, property.id)
    end

    x += 1
  end  
end

def do_property(playerId, propertyId)
  player = $players.find { |p| p.id == playerId }
  property = $properties.find { |p| p.id == propertyId }  

  if property.owner_id == 0
    if player.money >= property.price
      purchase_property(player.id, property.id)
    else
      game_over(player.name)
    end
  else
    if property.owner_id != player.id
      if player.money >= property.rent
        pay_rent(player.id, property.id)
      else
        game_over(player.name)
      end
    end
  end
end

def purchase_property(player_id, property_id)
  player = $players.find { |p| p.id == player_id }
  property = $properties.find { |p| p.id == property_id }  

  player.money -= property.price
  property.owner_id = player.id

  puts "#{player.name} purchased #{property.name} for $#{property.price}. Remaining: $#{player.money}"

  check_property_owner(property.color, player.id, player.name)
end

def check_property_owner(color, player_id, player_name)
  player = $players.find { |p| p.id == player_id }
  
  is_color_same_owner = $properties.select { |p| p.color == color }.all? { |p| p.owner_id == player_id }

  if is_color_same_owner
    puts "#{player_name} owns all #{color} properties. Rent is doubled!"

    $properties.each do |prop|
      if prop.color == color && prop.owner_id == player_id
        prop.rent *= 2
        puts "#{prop.name} rent is increased to #{prop.rent}"
      end
    end
  end
end

def roll_dice(playerId, dice)
  player = $players.find { |p| p.id == playerId }
  position_current = player.position
  position_new = position_current + dice

  if position_new > $boundary
    position_new -= $boundary
    player.money += 1
    puts "#{player.name} passed GO and collected $1."
  end

  player.position = position_new

  puts "#{player.name} rolled #{dice} and moved from #{position_current} to #{position_new}. Current money: $#{player.money}"
end

def pay_rent(player_id, property_id)
  property = $properties.find { |p| p.id == property_id }  
  owner = $players.find { |p| p.id == property.owner_id }  
  player = $players.find { |p| p.id == player_id }

  owner.money += property.rent
  player.money -= property.rent

  # puts "Owner of #{property_id}:#{property.name} is #{property.owner_id}. Rent is $#{property.rent}"
  puts "#{player.name} paid #{property.name}'s $#{property.rent} to #{owner.name}. #{player.name}: $#{player.money}. #{owner.name}: $#{owner.money}"

  if player.money.negative?
    game_over(player.name)
  end
end

def game_over(player_name)
  puts "#{player_name} is bankrupt!"

  winner = $players.max_by(&:money)
  puts "Winner is #{winner.name} with #{winner.money} money"

  $players.each do |player|
    place = player.position
    property = nil
    puts "#{player.name} has $#{player.money} at #{place}"
  end
end

$players = JSON.parse(File.read("players.json")).map { |p| Player.new(p) }
$properties = JSON.parse(File.read("board.json")).map { |p| Property.new(p) }
$boundary = $properties.length

$rolls_1 = JSON.parse(File.read("rolls_1.json"))
$rolls_2 = JSON.parse(File.read("rolls_2.json"))

puts "Start the game..."

# $players.each do |p|
#   puts "Player #{p.id}: #{p.name} has $#{p.money} and is at position #{p.position}"
# end 

# $properties.each do |p|
#   puts "Property #{p.id}: #{p.name} is a #{p.type} with price $#{p.price}, rent $#{p.rent}, color #{p.color}, owned by player #{p.owner_id}"
# end

run_game($rolls_1)

puts "Game Complete!"