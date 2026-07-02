using Godot;
using System.Text.Json;
using Core.Systems;
using TDSClicker.Core.Autoloads;
using TDSClicker.Entities;

namespace TDSClicker.Core.Systems;

public class SaveData
{
	public int Version { get; set; } = 1;
	public float Coins { get; set; } = 0;
	public float Droopers { get; set; } = 0;
	public float Autoclickers { get; set; } = 0;
	public bool FirstTime { get; set; } = true;
	public float Income { get; set; } = 0;
	public float EnemiesKilled { get; set; } = 0;
	public float CoinsEarned { get; set; } = 0;
	public string CurrentEnemy { get; set; } = "Normal";
	public float DrooperCooldown { get; set; } = 1;
	public float EnemyCoinMultiplier { get; set; } = 1;
	public bool SkipDisclaimer { get; set; } = false;
	public SettingsData Settings { get; set; } = new();
	public GlobalSettingsData GlobalSettings { get; set; } = new();
}

public class GlobalSettingsData
{
	public bool SkipDisclaimer { get; set; } = false;
	public string Language { get; set; } = "en";
}

public class SettingsData
{
	public bool BlurBg { get; set; } = false;
	public int CoinParticles { get; set; } = 100;
	public bool EnemyAnimations { get; set; } = true;
	public bool UiAnimations { get; set; } = true;
	public float MusicVolume { get; set; } = 1.0f;
	public float SoundVolume { get; set; } = 1.0f;
	public DropdownSelectionData DropdownSelection { get; set; } = new();
}

public class DropdownSelectionData
{
	public int CoinParticlesDropdown { get; set; } = 1;
	public int LanguageDropdown { get; set; } = 1;
}

public partial class SavingSystem : Node
{
	public static SavingSystem Instance { get; private set; }

	private const string SavePath = "user://savegame.json";

	public override void _Ready()
	{
		Instance = this;
	}

	private static readonly JsonSerializerOptions JsonOptions = new()
	{
		WriteIndented = true
	};
	
	public static void SaveGame()
	{
		var data = new SaveData
		{
			Version = 1,
			Coins = GameManager.Coins,
			Droopers = GameManager.TotalDroopers,
			Autoclickers = GameManager.Autoclickers,
			FirstTime = GameManager.FirstTime,
			Income = GameManager.Income,
			EnemiesKilled = GameManager.EnemiesKilled,
			CoinsEarned = GameManager.CoinsEarned,
			CurrentEnemy = GameManager.CurrentEnemy,
			DrooperCooldown = GameManager.DrooperCooldown,
			EnemyCoinMultiplier = Enemy.Instance.CoinMultiplier,
			SkipDisclaimer = Globals.Settings.SkipDisclaimer,
			
			GlobalSettings = new GlobalSettingsData
			{
				SkipDisclaimer = Globals.Settings.SkipDisclaimer,
				Language = Globals.Settings.Language,
			},
			
			Settings = new SettingsData
			{
				BlurBg = GameManager.Settings.BlurBg,
				CoinParticles = GameManager.Settings.CoinParticles,
				EnemyAnimations = GameManager.Settings.EnemyAnimations,
				UiAnimations = GameManager.Settings.UiAnimations,
				MusicVolume = GameManager.Settings.MusicVolume,
				SoundVolume = GameManager.Settings.SoundVolume,
				DropdownSelection = new DropdownSelectionData
				{
					CoinParticlesDropdown = GameManager.Settings.DropdownSelection.CoinParticlesDropdown,
					LanguageDropdown = GameManager.Settings.DropdownSelection.LanguageDropdown,
				}
			}
			
		};
		
		var json = JsonSerializer.Serialize(data, JsonOptions);

		using var file = FileAccess.Open(SavePath, FileAccess.ModeFlags.Write);
		file.StoreString(json);
	}

	public static SaveData LoadGame()
	{
		
		if (!FileAccess.FileExists(SavePath))
			return new SaveData();

		using var file = FileAccess.Open(SavePath, FileAccess.ModeFlags.Read);
		var json = file.GetAsText();

		var data = JsonSerializer.Deserialize<SaveData>(json);
		
		switch (data.Version)
		{
			case 1:
				break;

			default:
				GD.Print("Unknown save version.");
				break;
		}
		

		GameManager.ApplySave(data);
		return data ?? new SaveData();
	}
}
