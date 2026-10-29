using System;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Proto.CSharp;

public class Property
{
  private static int IdCounter = 0;

  public int Id {get; set;} = IdCounter++;

  [JsonPropertyName("name")]
  public required string Name {get; set;}

  [JsonPropertyName("price")]
  public int Price {get; set;}

  [JsonPropertyName("colour")]
  [JsonConverter(typeof(JsonStringEnumConverter))]
  public PropertyColor Color {get; set;}

  [JsonPropertyName("type")]
  [JsonConverter(typeof(JsonStringEnumConverter))]
  public PropertyType Type {get; set;}

  public int Rent {get; set;} = 1;

  public int OwnerId {get; set;} = 0;
  // public bool IsOwned {get; set;} = false;
}

public class ColorConverter: JsonConverter<PropertyColor>
{
  public override PropertyColor Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
  {
    string colorString = reader.GetString() ?? throw new JsonException("Color value is null");

    // if (Enum.TryParse<PropertyColor>(colorString, true, out var color))
    // {
    //   return color;
    // }
    // throw new JsonException($"Invalid color value: {colorString}");

    return colorString.ToLower() switch
    {
      "red" => PropertyColor.Red,
      "green" => PropertyColor.Green,
      "brown" => PropertyColor.Brown,
      "blue" => PropertyColor.Blue,
      _ => throw new JsonException($"Invalid type value: {colorString}")
    };

  }

  public override void Write(Utf8JsonWriter writer, PropertyColor value, JsonSerializerOptions options)
  {
    writer.WriteStringValue(value.ToString());
  }
}

public class TypeConverter: JsonConverter<PropertyType>
{
  public override PropertyType Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
  {
    string typeString = reader.GetString() ?? throw new JsonException("Type value is null");

    // if (Enum.TryParse<PropertyType>(typeString, true, out var type))
    // {
    //   return type;
    // }
    // throw new JsonException($"Invalid type value: {typeString}");

    return typeString.ToLower() switch
    {
      "property" => PropertyType.Property,
      "go" => PropertyType.Go,
      _ => throw new JsonException($"Invalid type value: {typeString}")
    };
  }

  public override void Write(Utf8JsonWriter writer, PropertyType value, JsonSerializerOptions options)
  {
    writer.WriteStringValue(value.ToString());
  }
}