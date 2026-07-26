using Godot;
namespace TDSClicker.Resources;

[GlobalClass]
public partial class UpgradeData : StoreData
{
    [Export] public int BasePrice {get; set;}
    [Export] public float PriceMultiplier {get; set;}
    [Export] public int Level {get; set;}
    [Export] public int MaxLevel {get; set;}
    [Export] public string UpgradeNameKey {get; set;}
    [Export] public string DescriptionKey {get; set;}
    [Export] public Color TextColor {get; set;}
}