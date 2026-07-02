using Godot;
using Godot.Collections;
namespace TDSClicker.Core.Systems;
using System.Globalization;
using Entities;

public partial class GameManager : Node2D
{
    public static GameManager Instance { get; private set; }
    private bool _running = true;

    public static float Coins = 0;
    public static float Income = 0;

    public static float TotalDroopers = 0;
    public static float DrooperCooldown = 0;
    public static float EnemiesKilled = 0;
    public static float Autoclickers = 0;
    public static bool FirstTime;
    
    public static float TotalIncome;
    public static float CoinsEarned;

    public static Dictionary Enemies = new Dictionary();
    public static Dictionary Upgrades = new Dictionary();
    public static Dictionary Droopers = new Dictionary();

    public static void ApplySave(SaveData data)
    {
        Coins = data.Coins;
        TotalDroopers = data.Droopers;
        Autoclickers = data.Autoclickers;
        FirstTime = data.FirstTime;
        Income = data.Income;
        EnemiesKilled = data.EnemiesKilled;
        CoinsEarned = data.CoinsEarned;
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
    
    [Export] public Enemy Enemy;
    [Export] public Node UiContainer;

    private Tween _coinCounterTween;
    
    public override void _Ready()
    {
        Instance = this;
        Enemy.EnemyHurt += _onEnemyHurt;
        TotalIncomeTimer.Timeout += _onTotalIncomeReset;
        SavingSystem.LoadGame();
        UpdateCounter(CounterTypes.All);
        _saveGameLoop();

        StatsButton.Pressed += _onStatsButtonPressed;
    }

    private static void _onStatsButtonPressed()
    {
        MenuManager.Instance.OpenMenu("Stats");
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
     UpdateCounter();
    }
    
    public void UpdateCounter(CounterTypes type = CounterTypes.Coins)
    {
        // Check for ui animations
        
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