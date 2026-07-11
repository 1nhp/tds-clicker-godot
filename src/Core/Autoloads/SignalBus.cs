using Godot;
namespace TDSClicker.Core.Autoloads;

public partial class SignalBus : Node
{
    public static SignalBus Instance { get; private set; }
    
    [Signal]
    public delegate void EnemyPurchasedEventHandler(string id = "");
    [Signal]
    public delegate void DrooperPurchasedEventHandler();
    [Signal]
    public delegate void PurchaseSuccesfullEventHandler();
    
    public override void _Ready()
    {
        Instance = this;
    }
}