using Godot;
using TDSClicker.Core.Systems;
using TDSClicker.Utils;

namespace TDSClicker.VFX;

public partial class CoinEffect : Node2D
{
    private Tween _coinEffectTween;
    
    public override void _EnterTree()
    {
        Scale = Vector2.Zero;
    }

    public override void _Ready()
    {
        var randomX = (float)GD.RandRange(-50, 50);
        var randomY = (float)GD.RandRange(-50, 50);
        
        Position += new Vector2(randomX, randomY);
        
        var coinIcon = GameManager.Instance.CoinIcon;
        
        _coinEffectTween?.Kill();
        _coinEffectTween = CreateTween();
        _coinEffectTween.Finished += _onTweenFinished;

        _coinEffectTween.SetTrans(Tween.TransitionType.Sine);
        var s = GD.RandRange(1, 2);
        _coinEffectTween.TweenProperty(this, "scale", new Vector2(s, s), 0.5f);
        _coinEffectTween.TweenProperty(this, "global_position", new Vector2(coinIcon.GlobalPosition.X + 20, coinIcon.GlobalPosition.Y + 20), (float)GD.RandRange(0.4f, 0.7f));
    }

    public override void _ExitTree()
    {
        _coinEffectTween.Finished -= _onTweenFinished;
    }

    private void _onTweenFinished()

    {
        ObjectHelper.Create<Node2D>("CoinBurstParticles", GlobalPosition, "/root/Game/FG/Objects/");
        
        SoundManager.Instance.PlaySound("CoinCollect");
        GameManager.Instance.UpdateCounter();
        QueueFree();
    }
}