using System.Text.Json.Serialization;

namespace Proto.CSharp;

public class Player
{
  public static int IdCounter = 1;

  public int Id {get; set;} = IdCounter++;

  [JsonPropertyName("name")]
  public required string Name {get; set;}

  // [JsonPropertyName("money")]
  public int Money {get; set;} = 16;

  // [JsonPropertyName("space")]
  //public required string Space {get; set;} 

  public int Position {get; set;} = 0;

  // public List<Property> Properties {get; set;} = new List<Property>();
}
