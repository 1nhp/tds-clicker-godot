namespace TDSClicker.scripts;
using Godot;
using System;
    
public partial class SoundManager : Node2D
{
    public static SoundManager Instance { get; private set; }

    public override void _Ready()
    {
        Instance = this;
    }

    public void PlaySound(NodePath node, float minPitch = 1, float maxPitch = 1, bool randomPitch = false)
    {
        var soundnode = GetNode<AudioStreamPlayer>(node);
        if (randomPitch) soundnode.PitchScale = (float)GD.RandRange(minPitch, maxPitch);
        soundnode.Play();
    }
}