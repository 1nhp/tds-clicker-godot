using Godot;
using System.Collections.Generic;
using TDSClicker.Core.Autoloads;
using TDSClicker.Core.Systems;
namespace TDSClicker.Core.Settings;

public partial class SettingsLogic : Node
{
    private readonly List<int> _particleOptions = [100, 30, 5, 1, 0];
    private readonly List<string> _languageOptions = ["En", "Ru"];
    
    [Export] public Node SettingsUi { get; set; }

    [Signal] public delegate void UpdateDlcButtonEventHandler();
    [Signal] public delegate void UpdateDataFinishedEventHandler();
    
    [Export] public OptionButton CoinParticlesCountDropdown { get; set; }
    [Export] public OptionButton LanguageDropdown { get; set; }

    [Export] public Slider AudioVolumeSlider { get; set; }
    [Export] public Slider MusicVolumeSlider { get; set; }

    public float AudioVolumeKey;
    public float MusicVolumeKey;
    public int CoinParticlesKey;
    public int LanguageKey;

    public override void _Ready()
    {
        UpdateData();
        CoinParticlesCountDropdown.ItemSelected += _onCoinParticlesCountDropdownSelected;
        LanguageDropdown.ItemSelected += _onLanguageDropdownSelected;

        AudioVolumeSlider.ValueChanged += _onAudioVolumeSliderValueChanged;
        MusicVolumeSlider.ValueChanged += _onMusicVolumeSliderValueChanged;
    }

    private void _onCoinParticlesCountDropdownSelected(long index)
    {
        GameManager.Settings.CoinParticles = _particleOptions[(int)index];
        GameManager.Settings.DropdownSelection.CoinParticlesDropdown = (int)index;
    }

    private void _onAudioVolumeSliderValueChanged(double value)
    {
        AudioServer.SetBusVolumeDb(2, (float)Mathf.LinearToDb(value));
        GameManager.Settings.SoundVolume = (float)value;
    }
  
    private void _onMusicVolumeSliderValueChanged(double value)
    {
        AudioServer.SetBusVolumeDb(1, (float)Mathf.LinearToDb(value));
        GameManager.Settings.MusicVolume = (float)value;
    }
    
    private void _onLanguageDropdownSelected(long index)
    {
        GD.Print(index);
        TranslationServer.SetLocale(_languageOptions[(int)index]);
        Globals.Settings.Language = _languageOptions[(int)index];
        GameManager.Settings.DropdownSelection.LanguageDropdown = (int)index;
    }
    
    public void UpdateData()
    {
        AudioVolumeKey = GameManager.Settings.SoundVolume;
        MusicVolumeKey = GameManager.Settings.MusicVolume;
        CoinParticlesKey = GameManager.Settings.DropdownSelection.CoinParticlesDropdown;
        LanguageKey = GameManager.Settings.DropdownSelection.LanguageDropdown;
        EmitSignal(SignalName.UpdateDataFinished);
    }
    
}