using Godot;
namespace TDSClicker.Core.Autoloads;

public partial class Globals : Node
{
	public static Globals Instance { get; private set; }

	public readonly string Version = "1.3 Beta indev CSharp";
	public bool RunningFromSource = true;

	public class GlobalSettings
	{
		public bool SkipDisclaimer { get; set; } = true;
		public string Language { get; set; } = "En";
	}

	public static GlobalSettings Settings = new();

	public override void _Ready()
	{
		TranslationServer.SetLocale(Settings.Language);

		// if running from source (not really true)
		if (Version.Contains("indev"))
		{
			RunningFromSource = true;
		}

		if (Settings.SkipDisclaimer)
		{
			GetTree().ChangeSceneToFile("res://scenes/game.tscn");
		}
	}
}
