using Godot;
using Godot.Collections;

[GlobalClass]
public partial class ObjectData : Resource
{
	[Export] public Dictionary<string, string> Object { get; set; } = new();
}
