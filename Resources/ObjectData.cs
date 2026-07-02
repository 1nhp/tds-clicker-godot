using System.IO;
using Godot;
using Godot.Collections;

[GlobalClass]
public partial class ObjectData : Resource
{
	[Export]
	public Dictionary Object { get; set; } = new Dictionary()
	{
		{ "ObjectName", "ObjectPath" },
	};
}
