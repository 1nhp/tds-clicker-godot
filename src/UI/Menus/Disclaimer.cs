using Godot;
using TDSClicker.Core.Autoloads;

namespace TDSClicker.UI;

public partial class Disclaimer : Node
{
    [Export] private AnimationPlayer _animPlayer;
    [Export] private Button _agreeButton;
    [Export] private Button _agreeButton2;
    [Export] private Button _agreeButton3;

    public override void _Ready()
    {
        _animPlayer.Play("anim");

        _agreeButton.Pressed += OnAgreeClicked;
        _agreeButton2.Pressed += OnAgree2Clicked;
        _agreeButton3.Pressed += OnAgree3Clicked;

        if (Globals.Settings.SkipDisclaimer)
        {
            GetTree().ChangeSceneToFile("res://Scenes/Game.tscn");
        }
    }

    private void OnAgreeClicked()
    {
        _animPlayer.Play("anim2");
    }
    private void OnAgree2Clicked()
    {
        _animPlayer.Play("anim3");
    }
    private void OnAgree3Clicked()
    {
        GetTree().ChangeSceneToFile("res://Scenes/Game.tscn");
    }
}
