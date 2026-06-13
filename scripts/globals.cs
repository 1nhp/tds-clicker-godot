using Godot;

/* Globals code rewritten in csharp */
 
public partial class globals : Node
{
	public static string language = "ru";
	public static string version = "1.3 Beta indev CSharp";
	public static bool running_from_source = true;
	public static Godot.Collections.Dictionary global_settings = new()
	{
		{ "skipDisclaimer", false },
		{ "language", "en" },
	};
	
	public override void _Ready()
	{
		TranslationServer.SetLocale(global_settings["language"].ToString());
		
		// if running from source (not really true)
		if (version.Contains("indev")) {
			running_from_source = true;
		}
		
		if (global_settings.TryGetValue("skipDisclaimer", out var value) && (bool)value)
		{
			GetTree().ChangeSceneToFile("res://scenes/game.tscn");
		}
	}
}
