using Godot;
namespace TDSClicker.Utils;

public static class PropertyHelper
{
    public static void Set<T>(
        GodotObject emitter,
        ref T field,
        T value,
        StringName signal)
    {
        field = value;
        emitter.EmitSignal(signal, Variant.From(value));
        GD.Print($"{signal}: {value}");
    }
}