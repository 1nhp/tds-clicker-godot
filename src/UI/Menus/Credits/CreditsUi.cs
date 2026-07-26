namespace TDSClicker.UI.Credits;

public partial class CreditsUi : MenuBase
{
    public static CreditsUi Instance { get; private set; }

    public override void _Ready()
    {
        base._Ready();
    }
    
    public override void _ExitTree()
    {
        if (Instance == this)
            Instance = null;

        base._ExitTree();
    }
}