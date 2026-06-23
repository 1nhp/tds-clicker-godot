using System.Numerics;
using Godot;
using Vector2 = Godot.Vector2;
using System;

namespace TDSClicker.scripts.helpers;

public partial class FancyButton : Button
{
	[Signal]
	public delegate void ClickedEventHandler();

	public enum AnimationType
	{
		Scale,
		Position
	}

	public enum Anim
	{
		HoverIn,
		HoverOut,
		Click
	}

	[Export] public bool OneClick { get; set; }
	[Export] public AnimationType ClickAnimation { get; set; } = AnimationType.Scale;
	[Export] public AnimationType HoverAnimation { get; set; } = AnimationType.Scale;
	[Export] public Vector2 HoverScale { get; set; } = new(1.05f, 1.05f);
	[Export] public Node ButtonNode { get; set; }
	
	private Vector2 _originalPosition;
	private bool _isHovered;
	
	public override void _Ready()
	{
		_originalPosition = Position;

		MouseEntered += OnMouseEntered;
		MouseExited += OnMouseExited;
		ButtonDown += OnMouseDown;
		Pressed += OnMouseClicked;
		ButtonInit();
	}


	public override void _ExitTree()
	{
		MouseEntered -= OnMouseEntered;
		MouseExited -= OnMouseExited;
		ButtonDown -= OnMouseDown;
		Pressed -= OnMouseClicked;
	}
	
	private static void ButtonInit()
	{
	}

	private void OnMouseEntered()
	{
		if (Disabled || _isHovered) return;
		SoundManager.Instance.PlaySound("ButtonHover");
		_isHovered = true;
		PlayAnim(Anim.HoverIn);
	}

	private void OnMouseExited()
	{
		if (Disabled || !_isHovered) return;
		_isHovered = false;
		PlayAnim(Anim.HoverOut);
	}

	private void OnMouseClicked()
	{
		if (Disabled) return;
		
		{
			SoundManager.Instance.PlaySound("ButtonDecide");
			EmitSignal(nameof(ClickedEventHandler));
			PlayAnim(Anim.Click);

			if (OneClick)
				Disabled = true;
		}
	}

	private void OnMouseDown()
	{
		if (!Disabled)
		{
			PlayAnim(Anim.Click);
		}
	}

	private Tween _buttonTween;

	/// <summary>
	/// Plays button animation.
	/// </summary>
	/// <param name="type">The type of animation e.g (Anim.HoverIn, Anim.HoverOut, Anim.Click)</param>
	private void PlayAnim(Anim type = Anim.HoverIn)
	{
		_buttonTween?.Kill();
		_buttonTween = CreateTween();
		_buttonTween.SetTrans(Tween.TransitionType.Back);
		
		switch (type)
		{
			case Anim.HoverIn:
				switch (HoverAnimation)
				{
					case AnimationType.Scale:
						_buttonTween.SetEase(Tween.EaseType.Out);
						_buttonTween.TweenProperty(ButtonNode, "scale", HoverScale * 1.02f, 0.1f);
						_buttonTween.TweenProperty(ButtonNode, "scale", HoverScale, 0.1f);
						break;

					case AnimationType.Position:
						_buttonTween.TweenProperty(ButtonNode, "position", _originalPosition + new Vector2(0, -6),
							0.1f);
						break;
					
					default:
						GD.Print("[FancyButton]: invalid Hover Animation type");
						break;
				}
				
				break;
			
			case Anim.HoverOut:
				switch (HoverAnimation)
				{
					case AnimationType.Scale:
						_buttonTween.TweenProperty(ButtonNode, "scale", Vector2.One, 0.1f);
						break;

					case AnimationType.Position:
						_buttonTween.TweenProperty(ButtonNode, "position", _originalPosition, 0.1f);
						break;
					
					default:
						GD.Print("[FancyButton]: invalid Hover Animation type");
						break;
				}

				break;

			case Anim.Click:
				switch (ClickAnimation)
				{
					case AnimationType.Scale:
						_buttonTween.TweenProperty(ButtonNode, "scale", new Vector2(0.95f, 0.95f), 0.05f);
						break;
					case AnimationType.Position:
						_buttonTween.TweenProperty(ButtonNode, "position", _originalPosition + new Vector2(0, -10),
							0.1f);
						break;
					
					default:
						GD.Print("[FancyButton]: invalid Click Animation type");
						break;
				}
				
				break;
			
			default:
				GD.Print("[FancyButton]: invalid Animation type");
				break;
		}
	}
}
