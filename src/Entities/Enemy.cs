using Godot;
using TDSClicker.Core.Autoloads;
using TDSClicker.Core.Systems;
using TDSClicker.Utils;

namespace TDSClicker.Entities;

public partial class Enemy : Node2D
{
	public static Enemy Instance { get; private set; }
	
	public enum EnemyTypes
	{
		Normal,
		Abnormal,
		Speedy,
	}

	public enum AnimTypes
	{
		HoverIn,
		HoverOut,
		Hurt,
	}

	public bool EnemyUpdating;
	
	  [Signal] public delegate void EnemyHurtEventHandler();
	  [Export] public int CoinAward { get; set; } = 1;
	  [Export] public int CoinMultiplier { get; set; } = 1;

	  [Export] public EnemyTypes EnemyType { get; set; }

	  public float Time;
	  public float Speed = 3.0f;
	  public float Amplitude = 0.3f;
	  
	  [Export] public Vector2 FinalScale { get; set; } = new (0.5f, 0.5f);
	  [Export] public Vector2 NormalScale { get; set; } = new (0.4f, 0.4f);
	  [Export] public Vector2 HoverScale { get; set; } = new (0.3f, 0.3f);
	  [Export] public Vector2 HurtScale { get; set; } = new (0.32f, 0.32f);
	  
	  [Export] public Sprite2D Sprite { get; set; }
	  [Export] public Sprite2D SpriteHurt { get; set; }
	  [Export] public Area2D Hit { get; set; }
	  [Export] public AnimationPlayer HurtAnim { get; set; }
	  
	  private Tween _enemyTween;

	  public override void _Ready()
	  {
		  Instance = this;
		  Hit.MouseEntered += OnMouseEntered;
		  Hit.MouseExited += OnMouseExited;
		  Hit.InputEvent += OnMouseClicked;
		  
		  SignalBus.Instance.EnemyPurchased += (name) => Update(name);
	  }

	  public async void Update(string name, bool animate = true)
	  {
		  if (EnemyUpdating) return;
		  var enemy = GD.Load<StoreData>("res://Resources/Store/Enemies/" + name + ".tres");
		  if (enemy == null) return;

		  EnemyUpdating = true;

		  if (animate)
		  {
			  _enemyTween?.Kill();
			  _enemyTween = CreateTween();
			  _enemyTween.SetTrans(Tween.TransitionType.Quad);
			  _enemyTween.TweenProperty(this, "scale", Vector2.Zero, 0.3f);
			  await ToSignal(_enemyTween, Tween.SignalName.Finished);

			  CoinAward = enemy.CoinAward;
			  Sprite.Texture = enemy.Texture;
			  SpriteHurt.Texture = enemy.Texture;

			  _enemyTween = CreateTween();
			  _enemyTween.SetTrans(Tween.TransitionType.Quad);
			  _enemyTween.TweenProperty(this, "scale", Vector2.One, 0.2f);
			  await ToSignal(_enemyTween, Tween.SignalName.Finished);
		  }
		  else
		  {
			  CoinAward = enemy.CoinAward;
			  Sprite.Texture = enemy.Texture;
			  SpriteHurt.Texture = enemy.Texture;
		  }

		  EnemyUpdating = false;
	  }

	  public override void _Process(double delta)
	  {
		  // Check for enemy animations

		  Time += (float) delta;
		  Sprite.Rotation = Mathf.Sin(Time * Speed) * Amplitude;
		  SpriteHurt.Rotation = Mathf.Sin(Time * Speed) * Amplitude;
	  }

	  private void OnMouseEntered()
	  {
		  Anim(AnimTypes.HoverIn);
	  }
	  private void OnMouseExited()
	  {
		  Anim(AnimTypes.HoverOut);
	  }

	  private void OnMouseClicked(Node viewport, InputEvent @event, long shapeIdx)
	  {
		  if (@event is InputEventMouseButton { ButtonIndex: MouseButton.Left, Pressed: true })
		  {
			  EmitSignal(SignalName.EnemyHurt);
			  
			  for (var i = 0; i < CoinAward; i++)
			  {
				  ObjectHelper.Create<Node2D>("CoinEffect", GlobalPosition, "/root/Game/FG/Objects/");         
			  }
			  
			  Anim(AnimTypes.Hurt);
			  SoundManager.Instance.PlaySound("EnemyKill1", 0.9f, 1.3f);
		  }
	  }
	  
	  private async void Anim(AnimTypes type)
	  {
		  _enemyTween?.Kill();
		  _enemyTween = CreateTween();
		  _enemyTween.SetTrans(Tween.TransitionType.Quad);

		  switch (type)
		  {
			  case AnimTypes.HoverIn:
				  _enemyTween.SetEase(Tween.EaseType.Out);               
				  _enemyTween.TweenProperty(Sprite, "scale", FinalScale, 0.15f);
				  break;

			  case AnimTypes.HoverOut:
				  _enemyTween.SetEase(Tween.EaseType.In);
				  _enemyTween.TweenProperty(Sprite, "scale", NormalScale, 0.15f);
				  break;

			  case AnimTypes.Hurt:
			  {
				  HurtAnim.Stop();
				  HurtAnim.Play("hurt");
				  _enemyTween.SetEase(Tween.EaseType.Out);
				  _enemyTween.TweenProperty(Sprite, "scale", HurtScale, 0.1f);

				  await ToSignal(GetTree().CreateTimer(0.04f), SceneTreeTimer.SignalName.Timeout);
				  
				  if (!IsInstanceValid(this)) return;
				  _enemyTween?.Kill();
				  _enemyTween = CreateTween();
				  _enemyTween.SetTrans(Tween.TransitionType.Quad);
				  _enemyTween.SetEase(Tween.EaseType.In);
				  _enemyTween.TweenProperty(Sprite, "scale", NormalScale, 0.15f);
				  break;
			  }
		  }
	  }
}
