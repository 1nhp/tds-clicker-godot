using System.Threading;
using Godot;
using Godot.Collections;
using TDSClicker.UI;
using TDSClicker.Utils;
using TDSClicker.VFX;
using Timer = Godot.Timer;

namespace TDSClicker.Core.Systems;
using System.Globalization;
using Entities;

public partial class GameManager : Node2D
{
	public static GameManager Instance { get; private set; }
	private bool _running = true;

	[Signal] public delegate void CoinsChangedEventHandler();
	[Signal] public delegate void IncomeChangedEventHandler();
	[Signal] public delegate void TotalIncomeChangedEventHandler();
	[Signal] public delegate void TotalDroopersChangedEventHandler();

	
	private static float _coins;
	public static float Coins
	{
		get => _coins;
		set => PropertyHelper.Set(Instance, ref _coins, value, SignalName.CoinsChanged);
	}
	private static float _income;
	public static float Income
	{
		get => _income;
		set => PropertyHelper.Set(Instance, ref _income, value, SignalName.IncomeChanged);
	}
	private static float _totalIncome;
	public static float TotalIncome
	{
		get => _totalIncome;
		set => PropertyHelper.Set(Instance, ref _totalIncome, value, SignalName.TotalIncomeChanged);
	}
	private static float _totalDroopers;
	public static float TotalDroopers
	{
		get => _totalDroopers;
		set => PropertyHelper.Set(Instance, ref _totalDroopers, value, SignalName.TotalDroopersChanged);
	}
	
	public static float DrooperCooldown = 1;
	public static float EnemiesKilled;
	public static float Autoclickers;
	public static bool FirstTime;
	
	public static float CoinsEarned;

	public static Dictionary<string, bool> Enemies { get; set; } = new();
	public static Dictionary<string, Dictionary<string, float>> Upgrades { get; set; } = new();
	public static Dictionary<string, Dictionary<string, float>> Droopers { get; set; } = new();
	
	public static class Settings
	{
		public static bool BlurBg = true;
		public static int CoinParticles = 5;
		public static bool EnemyAnimations = true;
		public static bool UiAnimations = true;
		public static float MusicVolume = 0.6f;
		public static float SoundVolume = 0.6f;

		public static class DropdownSelection
		{
			public static int CoinParticlesDropdown = 2;
			public static int LanguageDropdown;
		}
	}
	
	public static void ApplySave(SaveData data)
	{
		Coins = data.Coins;
		Droopers = data.Droopers;
		TotalDroopers = data.TotalDroopers;
		Autoclickers = data.Autoclickers;
		FirstTime = data.FirstTime;
		Income = data.Income;
		EnemiesKilled = data.EnemiesKilled;
		CoinsEarned = data.CoinsEarned;
		Enemies = data.Enemies;
		CurrentEnemy = data.CurrentEnemy;
		DrooperCooldown = data.DrooperCooldown;

		ApplySave(data.Settings);
	}
	
	public static void ApplySave(SettingsData settingsData)
	{
		Settings.BlurBg = settingsData.BlurBg;
		Settings.CoinParticles = settingsData.CoinParticles;
		Settings.EnemyAnimations = settingsData.EnemyAnimations;
		Settings.UiAnimations = settingsData.UiAnimations;
		Settings.SoundVolume = settingsData.SoundVolume;
		Settings.MusicVolume = settingsData.MusicVolume;
		Settings.DropdownSelection.CoinParticlesDropdown = settingsData.DropdownSelection.CoinParticlesDropdown;
		Settings.DropdownSelection.LanguageDropdown = settingsData.DropdownSelection.LanguageDropdown;
	}

	
	public enum CounterTypes
	{
		Coins,
		Droopers,
		Income,
		TotalIncome,
		All,
	}
	
	public static string CurrentEnemy = "Normal";
	
	[Export] public Label CoinCounter;
	[Export] public Label CoinCounter2;
	[Export] public Control CoinCounter3;
	
	[Export] public Label IncomeCounter;
	[Export] public Label IncomeCounter2;
	
	[Export] public Label TotalIncomeCounter;
	[Export] public Label TotalIncomeCounter2;
	[Export] public Timer TotalIncomeTimer;

	[Export] public Label DroopersCounter;
	[Export] public Label DroopersCounter2;
	[Export] public TextureRect CoinIcon;
	[Export] public TextureRect DrooperIcon;
	
	[Export] public ColorRect ScreenBlurCanvas;
	[Export] public AnimationPlayer ScreenBlurAnim;
	
	[Export] public Button StoreButton;
	[Export] public Button SettingsButton;
	[Export] public Button ChangeLogButton;
	[Export] public Button StatsButton;
	
	
	[Export] public Node Store { get; set; }
	[Export] private AnimationPlayer _storeAnim;
	
	[Export] public Enemy Enemy;
	[Export] public Node UiContainer;

	private Tween _coinCounterTween;
	
	public override void _Ready()
	{
		Instance = this;
		Enemy.EnemyHurt += _onEnemyHurt;
		TotalIncomeTimer.Timeout += _onTotalIncomeReset;
		SavingSystem.LoadGame();
		Enemy.Instance.Update(CurrentEnemy, false);
		UiCounter.Instance.UpdateCounter(UiCounter.CounterTypes.All);
		_saveGameLoop();
		_incomeLoop();
		
		AudioServer.SetBusVolumeDb(1, Mathf.LinearToDb(Settings.MusicVolume));
		AudioServer.SetBusVolumeDb(2, Mathf.LinearToDb(Settings.SoundVolume));

		StatsButton.Pressed += _onStatsButtonPressed;
		ChangeLogButton.Pressed += _onChangeLogButtonPressed;
		StoreButton.Pressed += _onStoreButtonPressed;
		SettingsButton.Pressed += _onSettingsButtonPressed;
	}

	private static void _onStoreButtonPressed()
	{
		MenuManager.Instance.OpenMenu(Instance.Store, Instance._storeAnim);
	}
	
	private static void _onStatsButtonPressed()
	{
		MenuManager.Instance.OpenMenu("Stats");
	}
	private static void _onChangeLogButtonPressed()
	{
		MenuManager.Instance.OpenMenu("Changelog");
	}
	private static void _onSettingsButtonPressed()
	{
		MenuManager.Instance.OpenMenu("Settings");
	}
	private async void _saveGameLoop()
	{
		while (_running)
		{
			await ToSignal(GetTree().CreateTimer(4.0f), SceneTreeTimer.SignalName.Timeout);
			if (!_running || !IsInsideTree())
				break;

			SavingSystem.SaveGame();
		}
	}
	
	private void _onTotalIncomeReset()
	{
		TotalIncome = 0;
	}
	
	private void _onEnemyHurt()
	{ 
	 Coins += Enemy.CoinAward;
	 SoundManager.Instance.PlaySound("Coin", 0.8f, 1.3f);
	 TotalIncome += Enemy.CoinAward * Enemy.CoinMultiplier;
	 CoinsEarned += Enemy.CoinAward * Enemy.CoinMultiplier;
	 EnemiesKilled += 1;
	}

	private async void _incomeLoop()
	{
		while (_running)
		{
			await ToSignal(GetTree().CreateTimer(DrooperCooldown), SceneTreeTimer.SignalName.Timeout);
			if (Income > 0)
			{
				Coins += Income;
				CoinsEarned += Income;
				TotalIncome += Income;
			
				for (var i = 0; i < Mathf.Min(Income, Settings.CoinParticles); i++)
				{
					var coineffect = ObjectHelper.Create<CoinEffect>("CoinEffect", new Vector2(DrooperIcon.GlobalPosition.X, DrooperIcon.GlobalPosition.Y + 30), "/root/Game/FG/Objects/");         
				}
				
				SoundManager.Instance.PlaySound("Coin2", 0.8f, 1.3f);
				UiCounter.Instance.UpdateCounter(UiCounter.CounterTypes.Droopers);
			} 
		}
	}
}
