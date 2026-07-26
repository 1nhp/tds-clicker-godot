using Godot;
using TDSClicker.Core.Systems;

namespace TDSClicker.VFX;

public static class ButtonAnimations
{
    public enum Type
    {
        Tint, 
        Scale, 
        Position
    }

    public static void HoverIn(Tween tween, Control target, Vector2 hoverScale)
    {
        tween.SetEase(Tween.EaseType.Out);
        tween.TweenProperty(target, "scale", hoverScale * 1.02f, 0.2f);
        tween.TweenProperty(target, "scale", hoverScale, 0.1f);
    }

    public static void HoverInPosition(Tween tween, Control target, Vector2 originalPos)
    {
        tween.TweenProperty(target, "position", originalPos + new Vector2(0, -6), 0.1f);
    }

    public static void HoverOutPosition(Tween tween, Control target, Vector2 originalPos)
    {
        tween.TweenProperty(target, "position",originalPos, 0.1f);
    }
    
    public static void Click(Tween tween, Control target)
    {
        tween.SetEase(Tween.EaseType.Out);
        tween.TweenProperty(target, "scale", new Vector2(0.90f, 0.90f), 0.3f);
    }

    public static void CustomAnimation(Tween tween, Button target, Type type)
    {
        if (GameManager.Settings.UiAnimations)
        {
            switch (type)
            {
                case Type.Tint:
                    tween.SetEase(Tween.EaseType.Out);
                    tween.SetTrans(Tween.TransitionType.Quad);
                    tween.TweenProperty(target, "modulate", new Color(2f, 2f, 2f), 0);
                    tween.TweenProperty(target, "modulate", new Color(1f, 1f, 1f), 0.5f);
                    break;
            } 
        }
    }
}