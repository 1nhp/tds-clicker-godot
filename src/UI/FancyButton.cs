using Godot;
using TDSClicker.Core.Systems;
using TDSClicker.VFX;

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
		Click,
	}

	[Export] public bool OneClick { get; set; }
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
	}

	public override void _ExitTree()
	{
		MouseEntered -= OnMouseEntered;
		MouseExited -= OnMouseExited;
		ButtonDown -= OnMouseDown;
		ButtonUp -= OnMouseExited;
		Pressed -= OnMouseClicked;
	}

	private void OnMouseEntered()
	{
		if (Disabled) return;
		SoundManager.Instance.PlaySound("ButtonHover");
		PlayAnim();
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
			GrabFocus();
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
	private Tween _customButtonTween;
	

	private Tween InitTween(Tween tween)
	{
		tween?.Kill();

		tween = CreateTween();
		tween.SetTrans(Tween.TransitionType.Back);
		tween.Finished += _checkForButtonState;

		return tween;
	}
	
	/// <summary>
	/// Plays button animation.
	/// </summary>
	/// <param name="type">The type of animation e.g (Anim.HoverIn, Anim.HoverOut, Anim.Click).</param>
	
	public void PlayAnim(Anim type = Anim.HoverIn)
	{
		_buttonTween = InitTween(_buttonTween);
		switch (type)
		{
			case Anim.HoverIn:
				if (HoverAnimation == AnimationType.Scale)
					ButtonAnimations.HoverIn(_buttonTween, this, HoverScale);
				else if (HoverAnimation == AnimationType.Position)
					ButtonAnimations.HoverInPosition(_buttonTween, this, _originalPosition);
				break;
			case Anim.HoverOut:
				if (HoverAnimation == AnimationType.Scale)
					ButtonAnimations.HoverIn(_buttonTween, this, Vector2.One);
				else if (HoverAnimation == AnimationType.Position)
					ButtonAnimations.HoverOutPosition(_buttonTween, this, _originalPosition);
				break;
			case Anim.Click:
				if (HoverAnimation == AnimationType.Scale)
					ButtonAnimations.Click(_buttonTween, this);
				break;
		}
	}
	
	public void PlayAnim(ButtonAnimations.Type type)
	{
		_customButtonTween = InitTween(_customButtonTween);
		ButtonAnimations.CustomAnimation(_customButtonTween, this, type);
	}
}
