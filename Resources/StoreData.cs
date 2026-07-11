using Godot;
using Godot.Collections;

[GlobalClass]
public partial class StoreData : Resource
{
    [Export] public string Id { get; set; }
    [Export] public string Name { get; set; }
    [Export] public Texture2D Texture { get; set; }
    [Export] public float Price { get; set; }
    [Export] public float PriceAddition { get; set; }
    [Export] public string Type { get; set; }
    [Export] public int CoinAward { get; set; }
}