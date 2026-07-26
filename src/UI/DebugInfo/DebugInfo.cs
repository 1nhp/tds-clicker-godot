using Godot;
using TDSClicker.Core.Systems;

namespace TDSClicker.UI.DebugInfo;

public partial class DebugInfo : Node
{
    [Export] public Label MusicLabel { get; set; }
    [Export] public Label FpsLabel { get; set; }

    public override void _Ready()
    {
        if(!OS.IsDebugBuild()) QueueFree();
        _UpdateInfo();
    }

    private async void _UpdateInfo()
    {
        if (!IsInstanceValid(this)) return;

        MusicLabel.Text = "Music: " + MusicManager.Instance?.Player?.Stream?.ResourceName;
        FpsLabel.Text = "FPS: " + Engine.GetFramesPerSecond();

        await ToSignal(GetTree().CreateTimer(1), SceneTreeTimer.SignalName.Timeout);
        _UpdateInfo();
    }
}