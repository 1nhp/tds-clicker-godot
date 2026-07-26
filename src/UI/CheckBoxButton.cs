using Godot;
using TDSClicker.Core.Autoloads;
using TDSClicker.Core.Systems;

namespace TDSClicker.UI;

public partial class CheckBoxButton : FancyButton
{
    [Export] public string Option { get; set; } = "blur_bg";
    [Export] public bool IsFromGlobals { get; set; }

    public override void _Ready()
    {
        base._Ready();
        
        CheckVarStatus();
        Toggled += _onToggled;
    }

    private void _onToggled(bool toggled)
    {
        var type = IsFromGlobals
            ? typeof(Globals.GlobalSettings)
            : typeof(GameManager.Settings);

        var field = type.GetField(
            Option,
            System.Reflection.BindingFlags.Public |
            System.Reflection.BindingFlags.Static);

        if (field == null) return;
        field.SetValue(null, toggled);
    }

    private void CheckVarStatus()
    {
        var type = IsFromGlobals
            ? typeof(Globals.GlobalSettings)
            : typeof(GameManager.Settings);

        var field = type.GetField(
            Option,
            System.Reflection.BindingFlags.Public |
            System.Reflection.BindingFlags.Static);

        if (field == null) return;
        

        bool status = (bool)field.GetValue(null)!;
        ButtonPressed = status;
    }
}