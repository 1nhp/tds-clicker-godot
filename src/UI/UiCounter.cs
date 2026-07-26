using System.Globalization;
using Godot;
namespace TDSClicker.UI;
using TDSClicker.Core.Systems;
	
public partial class UiCounter : Node
{
	public static UiCounter Instance { get; private set; }
	
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
	private Tween _DrooperIconTween;

	public enum CounterTypes
	{
		Coins,
		Droopers,
		Income,
		TotalIncome,
		All,
	}

	public override void _Ready()
	{
		Instance = this;
		CallDeferred(nameof(ConnectSignals));
	}

	private void ConnectSignals()
	{
		GameManager.Instance.CoinsChanged        += () => UpdateCounter(CounterTypes.Coins);
		GameManager.Instance.IncomeChanged       += () => UpdateCounter(CounterTypes.Income);
		GameManager.Instance.TotalIncomeChanged  += () => UpdateCounter(CounterTypes.TotalIncome);
		GameManager.Instance.TotalDroopersChanged += () => UpdateCounter(CounterTypes.Droopers);
	}

	public void UpdateCounter(CounterTypes type = CounterTypes.Coins)
	{
		GD.Print("Counter updated");
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
				
				if (!GameManager.Settings.UiAnimations) return;
				
				_coinCounterTween?.Kill();
				_coinCounterTween = CreateTween();
				_coinCounterTween.SetTrans(Tween.TransitionType.Quad);
				_coinCounterTween.TweenProperty(CoinCounter3, "scale", new Vector2(1.2f, 1.2f), 0.1f);
				_coinCounterTween.Parallel().TweenProperty(CoinIcon, "scale", new Vector2(1.2f, 1.2f), 0.1f);
		
				_coinCounterTween.TweenInterval(0.1f);
		
				_coinCounterTween.TweenProperty(CoinCounter3, "scale", new Vector2(1, 1), 0.1f);
				_coinCounterTween.Parallel().TweenProperty(CoinIcon, "scale", new Vector2(1, 1), 0.1f);
				break;
			case CounterTypes.Droopers:
				DroopersCounter.Text = GameManager.TotalDroopers.ToString(CultureInfo.InvariantCulture);
				DroopersCounter2.Text = GameManager.TotalDroopers.ToString(CultureInfo.InvariantCulture);
				
				_DrooperIconTween?.Kill();
				_DrooperIconTween = CreateTween();
				_DrooperIconTween.SetTrans(Tween.TransitionType.Quad);
				_DrooperIconTween.TweenProperty(DrooperIcon, "scale", new Vector2(1.3f, 1.3f), 0.1f);
				_DrooperIconTween.TweenProperty(DrooperIcon, "modulate", new Color(0f, 1f, 0f), 0.1f);
				_DrooperIconTween.TweenInterval(0.1f);
				_DrooperIconTween.TweenProperty(DrooperIcon, "scale", new Vector2(1, 1), 0.1f);
				_DrooperIconTween.TweenProperty(DrooperIcon, "modulate", new Color(1f, 1f, 1f), 0.1f);

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
