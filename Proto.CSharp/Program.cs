using Proto.CSharp;
using System.Text.Json;

Console.WriteLine("Start the game...");

List<Player> _players;
List<Property> _properties;
List<int> _rolls1 = new List<int>();
List<int> _rolls2 = new List<int>();
int _boundary = 0, _playerSize = 0;
bool _IsRun = true;

LoadJsonFile("players.json", out _players);
LoadJsonFile("board.json", out _properties);
LoadJsonFile("rolls_1.json", out _rolls1);
LoadJsonFile("rolls_2.json", out _rolls2);

_boundary = _properties.Count;
_playerSize = _players.Count;

RunGame(_rolls1);

Console.WriteLine("Game Complete!");

void RunGame(List<int> rolls)
{
  int size = rolls.Count();
  int x = 0;

  do
  {
    var player = _players[x%_playerSize];

    var dice = rolls[x];

    RollDice(ref player, dice);

    var property = _properties[player.Position];

    if(player.Position > 0)
    {
      DoProperty(player, property);  
    }

    x++;
    
  }while(_IsRun && x < size);

  
  Console.WriteLine($"Game Over! {_IsRun}, {x} : {size}");
}

void DoProperty(Player player, Property property)
{
  if(property.OwnerId == 0 )
  {
    if(player.Money >= property.Price)
    {
      PurchaseProperty(player.Id, property.Id);
    }
    else
    {
      GameOver(player.Name);
    }
  }
  else
  {
    if(property.OwnerId != player.Id)
    {
      if(player.Money >= property.Rent)
      {
        PayRent(player.Id, property.Id);
      }
      else
      {
        GameOver(player.Name);
      } 
    }
  }
}

void PurchaseProperty(int PlayerId, int PropertyId)
{
  Player player = _players.SingleOrDefault(p => p.Id == PlayerId)!;
  Property property = _properties[PropertyId];

  player.Money -= property.Price;

  //Buy the property
  property.OwnerId = player.Id;

  var color = property.Color;
  var playerId = player.Id;

  Console.WriteLine($"{player.Name} purchased {property.Name} for ${property.Price}. Remaining money: ${player.Money}");

  CheckPropertyOwner(color, playerId, player.Name);
}

void CheckPropertyOwner(PropertyColor color, int playerId, string playerName)
{
  var IsColorSameOwner = _properties.Where(p => p.Color == color).All(p => p.OwnerId == playerId);

  if(IsColorSameOwner)
  {
    Console.WriteLine($"{playerName} owns all {color} properties. Rent is doubled!");

    for(int i = 0; i < _properties.Count; i++)
    {
      Property prop = _properties[i];

      if(prop.Color == color && prop.OwnerId == playerId)
      {
        prop.Rent *= 2;
        Console.WriteLine($"{prop.Name} rent is increased to {prop.Rent}");
      }      
    }
  } 
}

void RollDice(ref Player player, int dice)
{
  int positionCurrent = player.Position;
  int positionNew = positionCurrent + dice;

  if(positionNew >= _boundary)
  {
    positionNew -= _boundary;
    player.Money += 1;   
    Console.WriteLine($"{player.Name} passed GO and collected $1."); 
  }

  player.Position = positionNew;

  Console.WriteLine($"{player.Name} rolled {dice} and moved from {positionCurrent} to {positionNew}. Current money: ${player.Money}");
}

void PayRent(int PlayerId, int PropertyId)
{  
  var property = _properties[PropertyId];

  var owner = _players.SingleOrDefault(p => p.Id == property.OwnerId)!;

  var player = _players.SingleOrDefault(p => p.Id == PlayerId)!;

  owner.Money += property.Rent;    

  player.Money -= property.Rent;

  Console.WriteLine($"{player.Name} paid {property.Name} ${property.Rent} to {owner.Name}. {player.Name}: ${player.Money}. Owner {owner.Name}: ${owner.Money}");

  if(player.Money < 0)
  {
    GameOver(player.Name);
  }
}

void GameOver(string playerName)
{
  _IsRun = false;

  Console.WriteLine($"{playerName} is bankrupt!");

  var winner = _players.OrderByDescending(p => p.Money).FirstOrDefault()!;

  Console.WriteLine($"Winner is {winner.Name} with {winner.Money} money");

  foreach(var player in _players)
  {
    var place = _properties[player.Position];

    Console.WriteLine($"{player.Name} has ${player.Money} at {place.Name}" );
  }
}

void LoadJsonFile<T>(string jsonFile, out List<T> list)
{
  string json = File.ReadAllText(jsonFile);

  list = JsonSerializer.Deserialize<List<T>>(json)!;
}

