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

	private static void SetVisible(Node node, bool visible)
	{
		switch (node)
		{
			case CanvasItem item:
				item.Visible = visible;
				break;

			case CanvasLayer layer:
				layer.Visible = visible;
				break;
		}
	}

	public void OpenMenu(Node menu, AnimationPlayer player)
	{
		SetVisible(menu, true);

		if (GameManager.Settings.UiAnimations)
		{
			player.Play("anim");
		}

		EmitSignal(SignalName.MenuOpening);
	}

	public Node OpenMenu(string sceneName, string anim = "anim")
	{
		var menu = ObjectHelper.Create<Control>(sceneName, Vector2.Zero, "/root/Game/UI");
		var player = menu.GetNode<AnimationPlayer>("AnimationPlayer");
		
		SetVisible(menu, true);

		if (GameManager.Settings.UiAnimations)
		{
			player.Play(anim);
		}

		EmitSignal(SignalName.MenuOpening, menu);
		return menu;
	}

	public async Task CloseMenu(
		Node menu,
		AnimationPlayer animPlayer,
		string animation = "anim",
		bool destroy = false,
		bool backwards = true)
	{
		if (GameManager.Settings.UiAnimations)
		{
			if (backwards)
				animPlayer.PlayBackwards(animation);
			else
				animPlayer.Play(animation);

			await ToSignal(animPlayer, AnimationPlayer.SignalName.AnimationFinished);

			foreach (Node child in menu.GetChildren())
			{
				if (child is AnimationPlayer player)
					player.Play("RESET");
			}
		}

		SetVisible(menu, false);
		EmitSignal(SignalName.MenuClosing, menu);

		if (destroy)
			menu.QueueFree();
	}
}
