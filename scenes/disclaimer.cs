using Godot;

/* Disclaimer code rewritten in csharp cause fuck GDscript interpreter*/

public partial class disclaimer : Node
{
	/*FIXED: Use exported node references instead of outright hardcoding them!*/
	[Export] 
	public AnimationPlayer animPlayer { get; set; }
	[Export] 
	public Button agree_button { get; set; }
	[Export] 
	public Button agree_button2 { get; set; }
	[Export] 
	public Button agree_button3 { get; set; }

	public override void _Ready()
	{
		animPlayer.Play("anim");
		
		agree_button.Pressed += on_agree_clicked;
		agree_button2.Pressed += on_agree2_clicked;
		agree_button3.Pressed += on_agree3_clicked;
	}
	
	public void on_agree_clicked(){
		animPlayer.Play("anim2");
	}
	public void on_agree2_clicked(){
		animPlayer.Play("anim3");
	}
	public void on_agree3_clicked(){
		GetTree().ChangeSceneToFile("res://scenes/game.tscn");
	}
}
