using Godot;
using TDSClicker.Core.Systems;
using TDSClicker.UI;

public abstract partial class MenuBase : Node
{
    [Export] public AnimationPlayer AnimPlayer { get; set; }
    [Export] public Control MenuRoot { get; set; }
    [Export] public FancyButton CloseButton { get; set; }

    public override void _Ready()
    {
        if (CloseButton != null)
            CloseButton.ClickedEvent += OnCloseButtonClicked;
    }

    public override void _ExitTree()
    {
        if (CloseButton != null)
            CloseButton.ClickedEvent -= OnCloseButtonClicked;
    }

    protected virtual async void OnCloseButtonClicked()
    {
        await MenuManager.Instance.CloseMenu(MenuRoot, AnimPlayer, "anim", true, true);
    }
}