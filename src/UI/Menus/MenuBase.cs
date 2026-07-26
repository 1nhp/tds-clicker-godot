using Godot;
using TDSClicker.Core.Systems;
using TDSClicker.UI;

public abstract partial class MenuBase : Node
{
    [Export] public AnimationPlayer AnimPlayer { get; set; }
    [Export] public Node MenuRoot { get; set; }
    [Export] public string ClosingAnimName { get; set; }
    [Export] public bool Backwards { get; set; } = true;
    [Export] public FancyButton CloseButton { get; set; }
    [Export] private bool DestroyAfterClosed { get; set; }

    public override void _Ready()
    {
        if (CloseButton != null)
            CloseButton.ClickedEvent += OnCloseButtonClicked;
    }
    
    public override void _ExitTree()
    {
        if (CloseButton != null)
        {
            CloseButton.ClickedEvent -= OnCloseButtonClicked;
        }
    }
    
    protected virtual async void OnCloseButtonClicked()
    {
        await MenuManager.Instance.CloseMenu(MenuRoot, AnimPlayer, ClosingAnimName, DestroyAfterClosed, Backwards);
    }
    
}