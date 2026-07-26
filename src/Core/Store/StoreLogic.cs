using System;
using Godot;
using Godot.Collections;
using TDSClicker.Core.Autoloads;
using TDSClicker.Core.Systems;
using TDSClicker.Entities;
using TDSClicker.Resources;

namespace TDSClicker.Core.Store;

public partial class StoreLogic : Node
{
	public static StoreLogic Instance { get; private set; }
	[Export] public Button BuyEnemyButton { get; set; }
	[Export] public Button BuyDrooperButton { get; set; }


	public override void _Ready()
	{
		BuyEnemyButton.Pressed += _OnBuyButtonClicked;
		BuyDrooperButton.Pressed += _OnBuyButtonClicked;
		Instance = this;
	}
	
	private void _OnBuyButtonClicked()
	{
		var item = StoreManager.Instance.CurrentItem;

		if (GameManager.Enemies.ContainsKey(item.Id))
		{
			Enemy.Instance.Update(item.Id);
			GameManager.CurrentEnemy = item.Id;
			return;
		}
		if (GameManager.Coins < item.Price)
		{
			GD.Print("Purchase failed");
			return;
		}
		switch (item.Type)
		{
			case "Enemy": _BuyEnemy(); break;
			case "Drooper": _BuyDrooper(item); break;
		}
	}

	private void _Transaction(float price)
	{
		GameManager.Coins -= price;
		SoundManager.Instance.PlaySound("Upgrade");
		GD.Print("Purchase succesful");
		SignalBus.Instance.EmitSignal(SignalBus.SignalName.PurchaseSuccesfull);
	}

	private void _BuyEnemy()
	{
		_Transaction(StoreManager.Instance.CurrentItem.Price);
		GameManager.Enemies[StoreManager.Instance.CurrentItem.Id] = true;
		GameManager.CurrentEnemy = StoreManager.Instance.CurrentItem.Id;
		SignalBus.Instance.EmitSignal(SignalBus.SignalName.EnemyPurchased, StoreManager.Instance.CurrentItem.Id);
	}

	private void _BuyDrooper(StoreData item)
	{
		GameManager.TotalDroopers += 1;
		GameManager.Income += item.CoinAward;

		if (!GameManager.Droopers.ContainsKey(item.Id))
		{
			GameManager.Droopers[item.Id] = new Dictionary<string, float>
			{
				{ "bought", 0 },
				{ "price", item.Price }
			};
		}

		var price = GameManager.Droopers[item.Id]["price"];
		GameManager.Droopers[item.Id]["bought"] += 1;
		GameManager.Droopers[item.Id]["price"] += item.PriceAddition;
		item.Price = GameManager.Droopers[item.Id]["price"];
		SignalBus.Instance.EmitSignal(SignalBus.SignalName.DrooperPurchased);

		_Transaction(price);
	}

	public bool BuyUpgrade(UpgradeData item)
	{
		var price = item.BasePrice * Math.Pow(item.PriceMultiplier, item.Level);
		if (GameManager.Coins < price)
		{
			return false;
		}
		if (item.Level >= item.MaxLevel)
		{
			return false;
		}
		_Transaction((float)price);
		item.Level += 1;
		
		if (!GameManager.Upgrades.ContainsKey(item.Id))
		{
			GameManager.Upgrades[item.Id] = new Dictionary<string, float>
			{
				{ "level", 1},
			};
		}
		
		GameManager.Upgrades[item.Id]["level"] = item.Level;
		_applyUpgradeEffect(item);
		return true;
	}

	private void _applyUpgradeEffect(UpgradeData item)
	{
		switch (item.Id)
		{
			case "DrooperCooldown":
			{
				GameManager.DrooperCooldown = Mathf.Max(0.0f, GameManager.DrooperCooldown - 0.1f);
				break;
			}
		}
	}
	
	public void UpdateItemState()
	{
		var current = StoreManager.Instance.CurrentItem;
		switch (current.Type)
		{
			case "Drooper":
			{
				if (GameManager.Droopers.TryGetValue(current.Id, out var drooperData))
				{
					current.Price = drooperData["price"];
				}
				break;
			}
		}
	}
}
