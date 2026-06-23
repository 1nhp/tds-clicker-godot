namespace TDSClicker.scenes.objects.enemy;
using Godot;
using System;
public class Enemy
{
	  public enum EnemyTypes
	  {
			Normal,
			Abnormal,
			Speedy,
	  }
	  
	  [Export] public int CoinAward { get; set; } = 1;
	  [Export] public EnemyTypes EnemyType { get; set; }
	  
	  public float Time = 0.0f;
	  public float Speed = 3.0f;
	  public float Amplitude = 0.3f;
	  
	  [Export] public Vector2 FinalScale { get; set; } = new (0.5f, 0.5f);
	  [Export] public Vector2 NormalScale { get; set; } = new (0.4f, 0.4f);
	  [Export] public Vector2 HoverScale { get; set; } = new (0.3f, 0.3f);

	  // Spawn coins code here

	  public Tween EnemyTween;
	  
	  
}
