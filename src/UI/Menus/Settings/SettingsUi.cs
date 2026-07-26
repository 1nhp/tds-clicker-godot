using Godot;
using TDSClicker.Core.Autoloads;
using TDSClicker.Core.Settings;
using TDSClicker.Core.Systems;
namespace TDSClicker.UI.Menus.Settings;

public partial class SettingsUi : MenuBase
{
	public static SettingsUi Instance { get; private set; }
	[Export] public SettingsLogic SettingsLogic { get; set; }

	[Export] public Control GraphicsTab { get; set; }
	[Export] public Control AudioTab { get; set; }
	[Export] public Control GameTab { get; set; }
	[Export] public Button GraphicsTabButton { get; set; }
	[Export] public Button AudioTabButton { get; set; }
	[Export] public Button GameTabButton { get; set; }
	[Export] public Button CreditsButton { get; set; }

	[Export] public Label GameVersion { get; set; }
	[Export] public Slider AudioVolumeSlider { get; set; }
	[Export] public Slider MusicVolumeSlider { get; set; }
	[Export] public OptionButton CoinParticlesDropdown { get; set; }
	[Export] public OptionButton LanguageDropdown { get; set; }
	[Export] public Button DownloadDlcButton { get; set; }
	[Export] public Button RemoveDlcButton { get; set; }
	[Export] public Button ResetSaveDataButton { get; set; }
	
	public override void _Ready()
	{
		Instance = this;
		base._Ready();
		
		GameVersion.Text = Globals.Version;
		
		GraphicsTabButton.Pressed += _onGraphicsTabButtonClicked;
		AudioTabButton.Pressed += _onAudioTabButtonClicked;
		GameTabButton.Pressed += _onGameTabButtonClicked;

		SettingsLogic.UpdateDataFinished += _onSettingsLogicUpdateDataFinished;
		CreditsButton.Pressed += () =>
		{
			MenuManager.Instance.OpenMenu("Credits");
		};
	}

	private void _onSettingsLogicUpdateDataFinished() { UpdateUi(); }

	public void UpdateUi()
	{
		AudioVolumeSlider.Value = SettingsLogic.AudioVolumeKey;
		MusicVolumeSlider.Value = SettingsLogic.AudioVolumeKey;
		CoinParticlesDropdown.Selected = SettingsLogic.CoinParticlesKey;
		LanguageDropdown.Selected = SettingsLogic.LanguageKey;
	}
	
	private void _onGraphicsTabButtonClicked() { SwitchTab(GraphicsTab); }
	private void _onAudioTabButtonClicked() { SwitchTab(AudioTab); }
	private void _onGameTabButtonClicked() { SwitchTab(GameTab); }

	private void SwitchTab(Control tab)
	{
		foreach (var t in new Control[] { GraphicsTab, AudioTab, GameTab })
		{
			t.Visible = false;
		}
		tab.Visible = true;
	}
	
	public override void _ExitTree()
	{
		if (Instance == this)
			Instance = null;

		base._ExitTree();
		
		GraphicsTabButton.Pressed -= _onGraphicsTabButtonClicked;
		AudioTabButton.Pressed -= _onAudioTabButtonClicked;
		GameTabButton.Pressed -= _onGameTabButtonClicked;

		SettingsLogic.UpdateDataFinished -= _onSettingsLogicUpdateDataFinished;
	}
}
