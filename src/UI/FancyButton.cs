using Godot;
using TDSClicker.Core.Systems;
using TDSClicker.Core.Systems;

namespace TDSClicker.UI;

public partial class FancyButton : Button
{
	[Signal]
	public delegate void ClickedEventEventHandler();
	
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

	[Export] public bool OneClick { get; set; } = false;
	[Export] public AnimationType ClickAnimation { get; set; } = AnimationType.Scale;
	[Export] public AnimationType HoverAnimation { get; set; } = AnimationType.Scale;
	[Export] public Vector2 HoverScale { get; set; } = new(1.05f, 1.05f);
	
	private Vector2 _originalPosition;
	
	public override void _Ready()
	{
		_originalPosition = Position;

		MouseEntered += OnMouseEntered;
		MouseExited += OnMouseExited;
		ButtonDown += OnMouseDown;
		ButtonUp += OnMouseExited;
		Pressed += OnMouseClicked;
		ButtonInit();
	}


	public override void _ExitTree()
	{
		MouseEntered -= OnMouseEntered;
		MouseExited -= OnMouseExited;
		ButtonDown -= OnMouseDown;
		ButtonUp -= OnMouseExited;
		Pressed -= OnMouseClicked;
	}
	
	private static void ButtonInit()
	{
	}

	private void OnMouseEntered()
	{
		if (Disabled) return;
		SoundManager.Instance.PlaySound("ButtonHover");
		PlayAnim();
		GD.Print(OneClick);
	}

	private void OnMouseExited()
	{
		PlayAnim(Anim.HoverOut);
	}

	private void OnMouseClicked()
	{
		{
			if (OneClick) Disabled = true;
			_checkForButtonState();
			SoundManager.Instance.PlaySound("ButtonDecide");
			EmitSignal(SignalName.ClickedEvent);
		}
	}

	private void OnMouseDown()
	{
		if (Disabled) return;
		
		PlayAnim(Anim.Click);
	}

	private void _checkForButtonState()
	{
		if (!Disabled) return;
		if (_buttonTween != null && _buttonTween.IsRunning()) return;
		
		Scale = Vector2.One;
		Position = _originalPosition;
	}
	
	private Tween _buttonTween;

	/// <summary>
	/// Plays button animation.
	/// </summary>
	/// <param name="type">The type of animation e.g (Anim.HoverIn, Anim.HoverOut, Anim.Click).</param>
	/// <param name="ease">The Ease of animation e.g (Tween.EaseType.In, Tween.EaseType.Out).</param>
	private async void PlayAnim(Anim type = Anim.HoverIn, Tween.EaseType ease = Tween.EaseType.Out)
	{
		_buttonTween?.Kill();
		_buttonTween = CreateTween();
		_buttonTween.SetTrans(Tween.TransitionType.Back);
		_buttonTween.SetEase(ease);
		_buttonTween.Finished += _checkForButtonState;
		
		switch (type)
		{
			case Anim.HoverIn:
				switch (HoverAnimation)
				{
					case AnimationType.Scale:
						_buttonTween.SetEase(Tween.EaseType.Out);
						_buttonTween.TweenProperty(this, "scale", HoverScale * 1.02f, 0.2f);
						_buttonTween.TweenProperty(this, "scale", HoverScale, 0.1f);
						break;

					case AnimationType.Position:
						_buttonTween.TweenProperty(this, "position", _originalPosition + new Vector2(0, -6),
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
						_buttonTween.TweenProperty(this, "scale", Vector2.One, 0.2f);
						break;

					case AnimationType.Position:
						_buttonTween.TweenProperty(this, "position", _originalPosition, 0.2f);
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
						_buttonTween.TweenProperty(this, "scale", new Vector2(0.90f, 0.90f), 0.3f);

						break;
					case AnimationType.Position:
						_buttonTween.TweenProperty(this, "position", _originalPosition + new Vector2(0, -10),
							0.2f);
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
