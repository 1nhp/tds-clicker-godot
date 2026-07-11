using System.Globalization;
using Godot;
namespace TDSClicker.UI;
using TDSClicker.Core.Systems;
    
public partial class UiCounter : Node
{
    public UiCounter Instance {get; private set;}
    
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
    
    private Tween _coinCounterTween;
    
    public enum CounterTypes
    {
        Coins,
        Droopers,
        Income,
        TotalIncome,
        All,
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
                CoinCounter.Text = ((int)GameManager.Coins).ToString(CultureInfo.InvariantCulture);
                CoinCounter2.Text = ((int)GameManager.Coins).ToString(CultureInfo.InvariantCulture);
                
                TotalIncomeCounter.Text = "+ " + GameManager.TotalIncome.ToString(CultureInfo.InvariantCulture);
                TotalIncomeCounter2.Text = "+ " + GameManager.TotalIncome.ToString(CultureInfo.InvariantCulture);
                
                _coinCounterTween?.Kill();
                _coinCounterTween = CreateTween();
                _coinCounterTween.TweenProperty(CoinCounter3, "scale", new Vector2(1.2f, 1.2f), 0.05f);
                _coinCounterTween.Parallel().TweenProperty(CoinIcon, "scale", new Vector2(1.2f, 1.2f), 0.05f);
        
                _coinCounterTween.TweenInterval(0.1f);
        
                _coinCounterTween.TweenProperty(CoinCounter3, "scale", new Vector2(1, 1), 0.05f);
                _coinCounterTween.Parallel().TweenProperty(CoinIcon, "scale", new Vector2(1, 1), 0.05f);
                break;
            case CounterTypes.Droopers:
                DroopersCounter.Text = GameManager.TotalDroopers.ToString(CultureInfo.InvariantCulture);
                DroopersCounter2.Text = GameManager.TotalDroopers.ToString(CultureInfo.InvariantCulture);
                break;
            case CounterTypes.Income:
                IncomeCounter.Text = GameManager.Income.ToString(CultureInfo.InvariantCulture);
                IncomeCounter2.Text = GameManager.Income.ToString(CultureInfo.InvariantCulture);
                break;
            case CounterTypes.TotalIncome:
                TotalIncomeCounter.Text = "+ " + GameManager.TotalIncome.ToString(CultureInfo.InvariantCulture);
                TotalIncomeCounter2.Text = "+ " + GameManager.TotalIncome.ToString(CultureInfo.InvariantCulture);
                break;
        }
    }
}