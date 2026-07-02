using Godot;
namespace TDSClicker.Utils;

public partial class ParticlesHelper : CpuParticles2D
{
    public override void _Ready()
    {
        Finished += _OnParticlesFinished;
        Emitting = true;
    }

    private void _OnParticlesFinished()
    {
        QueueFree();
        GetParent().QueueFree();
    }
}