using System.Threading.Tasks;
using Godot;
using TDSClicker.Utils;

namespace TDSClicker.Core.Systems;

public partial class MenuManager : Node
{
	public static MenuManager Instance { get; private set; }

	[Signal]
	public delegate void MenuOpeningEventHandler();

	[Signal]
	public delegate void MenuClosingEventHandler();

	public override void _Ready()
	{
		Instance = this;
	}

	public void OpenMenu(Node menu, AnimationPlayer player)
	{
		if (menu is CanvasLayer canvasItem)
			canvasItem.Visible = true;
			
		player.Play("anim");
		EmitSignal(SignalName.MenuOpening);
	}

	public Node OpenMenu(string sceneName)
	{
		var menu = ObjectHelper.Create<Control>(sceneName, Vector2.Zero, "/root/Game/UI");
		var player = menu.GetNode<AnimationPlayer>("AnimationPlayer");

		menu.Visible = true;
		player.Play("anim");
		EmitSignal(SignalName.MenuClosing);

		return menu;
	}

	public async Task CloseMenu(
		Node menuNode,
		AnimationPlayer animPlayer,
		string animation = "anim",
		bool destroy = false,
		bool backwards = true)
	{
		if (backwards)
			animPlayer.PlayBackwards(animation);
		else
			animPlayer.Play(animation);

		await ToSignal(animPlayer, AnimationPlayer.SignalName.AnimationFinished);

		foreach (Node child in menuNode.GetChildren())
		{
			if (child is AnimationPlayer player)
				player.Play("RESET");
		}

		if (menuNode is CanvasLayer canvasItem)
			canvasItem.Visible = false;

		EmitSignal(SignalName.MenuClosing);

		if (destroy)
			menuNode.QueueFree();
	}
}
