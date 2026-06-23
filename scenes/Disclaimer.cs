using Godot;

/* Disclaimer code rewritten in csharp cause fuck GDscript interpreter*/

public partial class Disclaimer : Node
{
    /*FIXED: Use exported node references instead of outright hardcoding them!*/
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
        GetTree().ChangeSceneToFile("res://scenes/game.tscn");
    }
}
