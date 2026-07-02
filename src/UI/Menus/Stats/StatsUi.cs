using Godot;
using TDSClicker.Core.Systems;

namespace TDSClicker.UI.Menus.Stats;

public partial class StatsUi : MenuBase
{
    public static StatsUi Instance { get; private set; }

    [Export] public Label EnemiesKilledLabel { get; set; }
    [Export] public Label DroopersBoughtLabel { get; set; }
    [Export] public Label UpgradesBoughtLabel { get; set; }
    [Export] public Label EnemiesBoughtLabel { get; set; }
    [Export] public Label TimePlayedLabel { get; set; }
    [Export] public Label CoinsEarnedLabel { get; set; }


    public float Upgrades = 0;
    public float Enemies = 0;

    public override void _Ready()
    {
        Instance = this;
        base._Ready();

        Enemies = GameManager.Enemies.Count;
        Upgrades = GameManager.Upgrades.Count;

        EnemiesKilledLabel.Text = Tr("enemies_killed") + GameManager.EnemiesKilled;
        DroopersBoughtLabel.Text = Tr("droopers_bought") + GameManager.TotalDroopers;
        UpgradesBoughtLabel.Text = Tr("upgrades_bought") + Upgrades;
        EnemiesBoughtLabel.Text = Tr("enemies_bought") + Enemies;
        TimePlayedLabel.Text = Tr("time_played") + GameManager.Enemies;
        CoinsEarnedLabel.Text = Tr("coins_earned") + GameManager.CoinsEarned;
    }

    public override void _ExitTree()
    {
        if (Instance == this)
            Instance = null;

        base._ExitTree();
    }
}