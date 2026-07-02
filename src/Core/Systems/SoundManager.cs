using Godot;
using System;
namespace TDSClicker.Core.Systems;

public partial class SoundManager : Node2D
{
	public static SoundManager Instance { get; private set; }

	public override void _Ready()
	{
		Instance = this;
	}

	public void PlaySound(NodePath node, float minPitch = 1, float maxPitch = 1, bool randomPitch = false)
	{
		var soundnode = GetNodeOrNull(node);

		switch (soundnode)
		{
			case AudioStreamPlayer player:
				if (randomPitch) player.PitchScale = (float)GD.RandRange(minPitch, maxPitch);
				player.Play();
				break;
			
			case AudioStreamPlayer2D player2D:
			{
				if (randomPitch) player2D.PitchScale = (float)GD.RandRange(minPitch, maxPitch);
				player2D.Play();
				break;
			}
		}
	}
}
