using System;
using System.Globalization;
using System.Text.RegularExpressions;
using Godot;
using TDSClicker.Core.Autoloads;
using TDSClicker.Core.Store;
using TDSClicker.Core.Systems;
using TDSClicker.Resources;
using TDSClicker.Utils;
using TDSClicker.VFX;

namespace TDSClicker.UI.Menus.Store;

public partial class StoreUi : MenuBase
{
	[Export] public AnimationPlayer ListAnimPlayer { get; set;}
	[Export] public AnimationPlayer ContentAnimPlayer { get; set;}
	[Export] public AnimationPlayer TabButtonsAnimPlayer { get; set;}
	[Export] public AnimationPlayer HeaderAnimPlayer { get; set;}

	[Export] public Panel StoreWindow { get; set;}
	[Export] public CanvasLayer StoreRoot { get; set;}
	[Export] public Node StoreManagerNode { get; set;}
	[Export] public StoreLogic StoreLogic;

	[Export] public Node EnemyContainer { get; set;}
	[Export] public Node DrooperContainer { get; set;}
	[Export] public Node UpgradeContainer { get; set;}
	[Export] public Node EnemyContentContainer { get; set;}
	[Export] public Node DrooperContentContainer { get; set;}

	[Export] public Panel EnemiesTab { get; set;}
	[Export] public Panel DroopersTab { get; set;}
	[Export] public Panel UpgradesTab { get; set;}
	
	[Export] public Button EnemiesButton { get; set;}
	[Export] public Button DroopersButton { get; set;}
	[Export] public Button UpgradesButton { get; set;}
	
	public  enum UiAnimTypes
	{
		Default,
		Content,
		Header,
		TabButtons,
		List,
	}
	
	private void PlayUiAnim(UiAnimTypes type)
	{
		if (GameManager.Settings.UiAnimations)
		{
			switch (type)
			{
				case UiAnimTypes.Content:
					ContentAnimPlayer.Stop();
					ContentAnimPlayer.Play("ContentAnim/content_anim");
					break;
				case UiAnimTypes.Header:
					HeaderAnimPlayer.Play("StoreHeaderAnim/anim");
					break;
				case UiAnimTypes.TabButtons:
					TabButtonsAnimPlayer.Play("TabButtons/tab_buttons_fade");
					break;
				case UiAnimTypes.List:
					ContentAnimPlayer.Play("ListAnim/list_fade");
					break;
			
				default:
					ContentAnimPlayer.Stop();
					ListAnimPlayer.Stop();
					ContentAnimPlayer.Play("ContentAnim/content_anim");
					ListAnimPlayer.Play("ListAnim/list_fade");
					break;
			}		
		}
		else
		{
			EnemiesButton.Modulate = new Color(1f,1f,1f,1);
			DroopersButton.Modulate = new Color(1f,1f,1f,1);
			UpgradesButton.Modulate = new Color(1f,1f,1f,1);
		}
	}

	public override void _Ready()
	{
		EnemiesTab.Visible = false;
		DroopersTab.Visible = false;
		UpgradesTab.Visible = false;
		base._Ready();
		
		MenuManager.Instance.MenuOpening += _MenuOpened;
		
		EnemiesButton.Pressed += _onEnemiesButtonClicked;
		DroopersButton.Pressed += _onDroopersButtonClicked;
		UpgradesButton.Pressed += _onUpgradesButtonClicked;

		StoreManager.Instance.LoadingFinished += _onStoreManagerLoadingFinished;
		SignalBus.Instance.EnemyPurchased += _onEnemyPurchased;
		SignalBus.Instance.DrooperPurchased += _onDrooperPurchased;
		SignalBus.Instance.PurchaseSuccesfull += _onPurchaseSuccesful;
	}
	
	private void _onEnemiesButtonClicked() { SwitchTab(EnemiesTab); }
	private void _onDroopersButtonClicked() { SwitchTab(DroopersTab); }
	private void _onUpgradesButtonClicked() { SwitchTab(UpgradesTab); }
	
	private async void _MenuOpened()
	{
		SwitchTab(EnemiesTab);
		SoundManager.Instance.PlaySound("StoreOpen");
		PlayUiAnim(UiAnimTypes.Header);
		await ToSignal(GetTree().CreateTimer(0.2f), "timeout");
		PlayUiAnim(UiAnimTypes.TabButtons);
	}
	
	private void SwitchTab(Panel tab)
	{
		PlayUiAnim(UiAnimTypes.Default);

		foreach (var t in new Panel[] { DroopersTab, EnemiesTab, UpgradesTab })
		{
			t.Visible = false;
		}
		tab.Visible = true;
	}
	
	public void CreateButton(StoreData item, Node container)
	{
		var storeSelectButton = ObjectHelper.Create<Button>("StoreSelectButton", Vector2.Zero, container.GetPath());
		storeSelectButton.Icon = item.Texture;
		storeSelectButton.Name = item.Name;

		storeSelectButton.CustomMinimumSize = new Vector2(64, 64);
		storeSelectButton.SetMeta("item", item);
		storeSelectButton.Pressed += () => _onItemClicked(storeSelectButton);
	}

	public void CreateUpgrade(UpgradeData item, Node container)
	{
		var upgradeContainer = ObjectHelper.Create<Control>("StoreUpgradeContainer", Vector2.Zero, container.GetPath());
		
		var buyButton = upgradeContainer.GetNode<Button>("Panel/Buy");
		buyButton.SetMeta("item", item);
		buyButton.Pressed += () => _onUpgradeClicked(item, upgradeContainer);

		StoreManager.Instance.UpgradeContainers[item.Id] = upgradeContainer;
		StoreManager.Instance.UpgradeData[item.Id] = item;

		upgradeContainer.CustomMinimumSize = new Vector2(50, 75);
		UpdateUpgradeContainer(upgradeContainer, item);
		
	}

	private void _onUpgradeClicked(UpgradeData item, Node container)
	{
		var status = StoreLogic.BuyUpgrade(item);
		if (!status) return;

		UpdateUpgradeContainer(container, item);
		container.GetNode<Panel>("Panel").GetNode<FancyButton>("Buy").PlayAnim(ButtonAnimations.Type.Tint);
	}
	
	private void _onStoreManagerLoadingFinished()
	{
		foreach (var resource in StoreManager.Instance.StoreItems)
		{
			if (resource is StoreData storeItem)
			{
				switch (storeItem.Type)
				{
					case "Enemy":
						CreateButton(storeItem, EnemyContainer);
						break;
					case "Drooper":
						CreateButton(storeItem, DrooperContainer);
						break;
				}
			}
			if (resource is UpgradeData upgradeItem)
			{
				CreateUpgrade(upgradeItem, UpgradeContainer);
			}
		}
	}

	private void FillContent(Node container, StoreData item, string rateText, bool onlyPrice = false)
	{
		StoreLogic.Instance.UpdateItemState();
		
		var nameLabel = container.GetNode<Label>("Name");
		var priceLabel = container.GetNode<Label>("Price");
		var coinAwardLabel = container.GetNode<Label>("CoinAward");
		var image = container.GetNode<TextureRect>("Image");
		
		if (!onlyPrice)
		{
			nameLabel.Text = item.Name;
			coinAwardLabel.Text = rateText;
			image.Texture = item.Texture;
			var displayItemPrice = NumFormat.FormatNumber(item.Price);
			priceLabel.Text = Tr("price") + displayItemPrice.ToString(CultureInfo.InvariantCulture);
		}
		else
		{
			var displayItemPrice = NumFormat.FormatNumber(item.Price);
			priceLabel.Text = Tr("price") + displayItemPrice.ToString(CultureInfo.InvariantCulture);
		}
		
		if (container is Panel panel)
			panel.Visible = true;
	}

	private void UpdateUpgradeContainer(Node container, UpgradeData item)
	{
		var control = container.GetNode<Panel>("Panel");	
		var upgradeName = control.GetNode<Label>("upgradeName");
		var upgradePrice = control.GetNode<Label>("upgradePrice");
		var upgradeDescription = control.GetNode<Label>("upgradeDescription");
		var upgradeVar = control.GetNode<Label>("Var");
		var buyButton = control.GetNode<Button>("Buy");

		var icon = control.GetNode<TextureRect>("Icon");
		var price = item.BasePrice * Math.Pow(item.PriceMultiplier, item.Level);
		var displayPrice = NumFormat.FormatNumber(price);
		
		upgradeName.Text = Tr(item.UpgradeNameKey);
		upgradePrice.Text = Tr("price") + displayPrice;
		icon.Texture = item.Texture;
		upgradeDescription.Text = Tr(item.DescriptionKey);

		var text = "Placeholder";
		upgradeVar.Text = text;
		upgradeVar.AddThemeColorOverride("font_color", item.TextColor);
		buyButton.Text = Tr("upgrade_btn") + item.Level;
	}
	
	private void UpdateContent(StoreData item)
	{
		if (item == null) return;
		switch (item.Type)
		{
			case "Enemy": 
				UpdateEnemyBuyButton(item.Id);
				FillContent(EnemyContentContainer, item, NumFormat.FormatNumber(item.CoinAward) + " " + Tr("per_click")); 
				break;
			case "Drooper":
				FillContent(DrooperContentContainer, item, NumFormat.FormatNumber(item.CoinAward) + " " + Tr("per_second"), true);
				break;
		}
	}
	
	private void _onItemClicked(Button button)
	{
		StoreManager.Instance.CurrentItem = button.GetMeta("item").As<StoreData>();
		UpdateContent(StoreManager.Instance.CurrentItem);
		PlayUiAnim(UiAnimTypes.Content);
	}

	private void _onEnemyPurchased(string id = "")
	{
		UpdateEnemyBuyButton(id);
		EnemyContentContainer.GetNode<FancyButton>("Buy").PlayAnim(ButtonAnimations.Type.Tint);
	}

	private void _onDrooperPurchased()
	{
		DrooperContentContainer.GetNode<FancyButton>("Buy").PlayAnim(ButtonAnimations.Type.Tint);
	}
	
	public void UpdateEnemyBuyButton(string id = "")
	{
		if (GameManager.Enemies.ContainsKey(id).Equals(true))
		{
			EnemyContentContainer.GetNode<Button>("Buy").Text = Tr("enemy_change_btn");
		}
		else
		{
			EnemyContentContainer.GetNode<Button>("Buy").Text = Tr("buy_btn");
		}
	}

	private void _onPurchaseSuccesful()
	{
		UpdateContent(StoreManager.Instance.CurrentItem);
		ObjectHelper.Create<Node2D>("CoinParticles", GetViewport().GetMousePosition(), "/root/Game/UI/Store");
	}
}
