using Godot;
using Godot.Collections;
using TDSClicker.Utils;

namespace TDSClicker.Core.Systems;
using System.Globalization;
using Entities;
using TDSClicker.Utils;

public partial class GameManager : Node2D
{
    public static GameManager Instance { get; private set; }
    private bool _running = true;

    [Signal] public delegate void CoinsChangedEventHandler(float coins);
    [Signal] public delegate void IncomeChangedEventHandler(float income);
    [Signal] public delegate void TotalIncomeChangedEventHandler(float totalIncome);
    [Signal] public delegate void TotalDroopersChangedEventHandler(float totalDroopers);

    
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
    
    
    public static float DrooperCooldown = 0;
    public static float EnemiesKilled = 0;
    public static float Autoclickers = 0;
    public static bool FirstTime;
    
    public static float CoinsEarned;

    public static Dictionary<string, bool> Enemies { get; set; } = new();
    public static Dictionary<string, bool> Upgrades { get; set; } = new();
    public static Dictionary<string, Dictionary<string, float>> Droopers { get; set; } = new();

    
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
    }

    public static class Settings
    {
        public static bool BlurBg = false;
        public static int CoinParticles = 100;
        public static bool EnemyAnimations = true;
        public static bool UiAnimations = true;
        public static float MusicVolume = 1.0f;
        public static float SoundVolume = 1.0f;

        public static class DropdownSelection
        {
            public static int CoinParticlesDropdown = 1;
            public static int LanguageDropdown = 1;
        }

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
        UpdateCounter(CounterTypes.All);
        _saveGameLoop();

        StatsButton.Pressed += _onStatsButtonPressed;
        ChangeLogButton.Pressed += _onChangeLogButtonPressed;
        StoreButton.Pressed += _onStoreButtonPressed;
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
        UpdateCounter(CounterTypes.TotalIncome);
    }
    
    private void _onEnemyHurt()
    { 
     Coins += Enemy.CoinAward;
     SoundManager.Instance.PlaySound("Coin", 0.8f, 1.3f);
     TotalIncome += Enemy.CoinAward * Enemy.CoinMultiplier;
     CoinsEarned += Enemy.CoinAward * Enemy.CoinMultiplier;
     EnemiesKilled += 1;
    }
    
    public void UpdateCounter(CounterTypes type = CounterTypes.Coins)
    {
        if (type == CounterTypes.All)
        {
            UpdateCounter();
            UpdateCounter(CounterTypes.Droopers);
            UpdateCounter(CounterTypes.Income);
            UpdateCounter(CounterTypes.TotalIncome);
            return;
        }
        
        switch (type)
        {
            case CounterTypes.Coins:
                CoinCounter.Text = ((int)Coins).ToString(CultureInfo.InvariantCulture);
                CoinCounter2.Text = ((int)Coins).ToString(CultureInfo.InvariantCulture);
                
                TotalIncomeCounter.Text = "+ " + TotalIncome.ToString(CultureInfo.InvariantCulture);
                TotalIncomeCounter2.Text = "+ " + TotalIncome.ToString(CultureInfo.InvariantCulture);
                
                _coinCounterTween?.Kill();
                _coinCounterTween = CreateTween();
                _coinCounterTween.TweenProperty(CoinCounter3, "scale", new Vector2(1.2f, 1.2f), 0.05f);
                _coinCounterTween.Parallel().TweenProperty(CoinIcon, "scale", new Vector2(1.2f, 1.2f), 0.05f);
        
                _coinCounterTween.TweenInterval(0.1f);
        
                _coinCounterTween.TweenProperty(CoinCounter3, "scale", new Vector2(1, 1), 0.05f);
                _coinCounterTween.Parallel().TweenProperty(CoinIcon, "scale", new Vector2(1, 1), 0.05f);
                break;
            case CounterTypes.Droopers:
                DroopersCounter.Text = TotalDroopers.ToString(CultureInfo.InvariantCulture);
                DroopersCounter2.Text = TotalDroopers.ToString(CultureInfo.InvariantCulture);
                break;
            case CounterTypes.Income:
                IncomeCounter.Text = Income.ToString(CultureInfo.InvariantCulture);
                IncomeCounter2.Text = Income.ToString(CultureInfo.InvariantCulture);
                break;
            case CounterTypes.TotalIncome:
                TotalIncomeCounter.Text = "+ " + TotalIncome.ToString(CultureInfo.InvariantCulture);
                TotalIncomeCounter2.Text = "+ " + TotalIncome.ToString(CultureInfo.InvariantCulture);
                break;
        }
    }
}