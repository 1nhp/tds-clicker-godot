using Godot;
using TDSClicker.Core.Systems;
using TDSClicker.Entities;

namespace Core.Systems;

public partial class Debug : Node
{
    public override void _Ready()
    {
        if (!OS.IsDebugBuild()) QueueFree();
    }
    
    public override void _UnhandledInput(InputEvent @event)
    {
        if (Input.IsKeyPressed(Key.R))
        {
            GetTree().ReloadCurrentScene();
        }
        if (Input.IsKeyPressed(Key.Escape))
        {
            GetTree().Quit();
        }
        if (Input.IsKeyPressed(Key.C))
        {
            GameManager.Coins += 10000000000;
        }
        if (Input.IsKeyPressed(Key.E))
        {
            Enemy.Instance.Update("Abnormal");
        }
    }
}