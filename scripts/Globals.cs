using Godot;
namespace TDSClicker.scripts;

/* Globals code rewritten in csharp */

public partial class Globals : Node
{
    public static Globals Instance { get; private set; }
    
    public static Node Game;
    public static string Language = "ru";
    public static string Version = "1.3 Beta indev CSharp";
    public static bool RunningFromSource = true;
    public class GlobalSettings
    {
        public bool SkipDisclaimer { get; set; } = false;
        public string Language { get; set; } = "en";
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

    public void GetGame()
    {
        var GameRef = GetTree().GetNodesInGroup("game");

        if (GameRef.Count > 0)
        {
            Game = GameRef[0];
            GD.Print("GLOBALS: _get_game Game found!");
        }
        else
        {
            GD.Print("GLOBALS: _get_game Failed to find game!");
        }
    }
}
