#!/usr/bin/env ruby
require "json"

class MonopolyGame
  STARTING_MONEY = 16
  PLAYER_ORDER = %w[Peter Billy Charlotte Sweedal]

  def initialize(board_data, rolls_data)
    @board = board_data.map(&:dup)
    @rolls = rolls_data
    @players = PLAYER_ORDER.map do |name|
      {
        name: name,
        money: STARTING_MONEY,
        position: 0,
        bankrupt: false,
        has_started: false,
        properties: []
      }
    end

    @board.each do |space|
      next unless space["type"].to_s.downcase == "property"
      space["owner"] = nil
    end
  end

  def run
    turn_index = 0

    @rolls.each do |roll|
      player = @players[turn_index % @players.length]
      turn_index += 1

      break if player[:bankrupt]

      take_turn(player, roll)

      break if game_over?
    end

    finalize
  end

  private

  def take_turn(player, roll)
    return if player[:bankrupt]

    old_position = player[:position]
    board_size = @board.length

    if player[:has_started]
      passed_laps = ((old_position + roll) / board_size).floor
      player[:money] += passed_laps if passed_laps.positive?
    end

    player[:position] = (old_position + roll) % board_size
    player[:has_started] = true

    tile = current_tile(player)

    if tile["type"].to_s.downcase == "property"
      if tile["owner"].nil?
        buy_property(player, tile)
      elsif tile["owner"] != player[:name]
        pay_rent(player, tile)
      end
    end

    if player[:money] < 0
      player[:bankrupt] = true
    end
  end

  def current_tile(player)
    @board[player[:position]]
  end

  def buy_property(player, tile)
    cost = tile["price"].to_i
    if player[:money] >= cost
      player[:money] -= cost
      tile["owner"] = player[:name]
      player[:properties] << tile["name"]
    else
      player[:bankrupt] = true
    end
  end

  def pay_rent(player, tile)
    owner_name = tile["owner"]
    owner = @players.find { |p| p[:name] == owner_name }
    return if owner.nil? || owner[:name] == player[:name]

    rent = tile["price"].to_i
    rent *= 2 if complete_set?(owner_name, tile["colour"])

    player[:money] -= rent
    owner[:money] += rent

    if player[:money] < 0
      player[:bankrupt] = true
    end
  end

  def complete_set?(owner_name, colour)
    colour_properties = @board.select do |space|
      space["type"].to_s.downcase == "property" &&
        space["colour"] == colour
    end

    colour_properties.empty? ? false : colour_properties.all? { |space| space["owner"] == owner_name }
  end

  def game_over?
    @players.any? { |p| p[:bankrupt] }
  end

  def finalize
    max_money = @players.map { |p| p[:money] }.max
    winners = @players.select { |p| p[:money] == max_money }.map { |p| p[:name] }

    players_result = @players.map do |player|
      {
        "name" => player[:name], 
        "money" => player[:money],
        "space" => @board[player[:position]]["name"]
      }
    end

    {
      "winners" => winners,
      "players" => players_result
    }
  end
end

if __FILE__ == $PROGRAM_NAME
  args = ARGV.dup
  json_mode = args.delete("--json")

  if args.length != 2
    abort "Usage: ruby monopoly.rb BOARD.json ROLLS.json [--json]"
  end

  board_path, rolls_path = args
  board = JSON.parse(File.read(board_path))
  rolls = JSON.parse(File.read(rolls_path))

  result = MonopolyGame.new(board, rolls).run

  if json_mode
    puts JSON.pretty_generate(result)
  else
    puts "Winner(s): #{result["winners"].join(", ")}"
    result["players"].each do |player|
      puts "#{player["name"]}: $#{player["money"]} on #{player["space"]}"
    end
  end
end 