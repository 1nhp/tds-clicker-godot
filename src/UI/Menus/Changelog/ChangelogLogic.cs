using System.Collections.Generic;
using Godot;
namespace TDSClicker.UI.Menus.Changelog;

public partial class ChangelogLogic : Node
{
	public List<ChangeLogData> Articles;
	
	[Signal]
	public delegate void OnGetArticlesFinishedEventHandler();
	
	public override void _Ready()
	{
		Articles = _GetArticles();
		EmitSignal(SignalName.OnGetArticlesFinished);
	}

	private static List<ChangeLogData> _GetArticles()
	{
		var articles = new List<ChangeLogData>();
		using var dir = DirAccess.Open("res://Resources/Changelogs/");
		
		dir.ListDirBegin();
		var fileName = dir.GetNext();
		
		while (fileName != "")
		{
			if (fileName.EndsWith(".tres"))
			{
				var path = "res://Resources/Changelogs/" + fileName;
				var item = GD.Load<ChangeLogData>(path);

				articles.Add(item);
			}
			fileName = dir.GetNext();
		}
		dir.ListDirEnd();
		return articles;
	}
}
