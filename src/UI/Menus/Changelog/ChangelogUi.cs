using Godot;
using TDSClicker.Core.Autoloads;
using TDSClicker.Core.Systems;
using TDSClicker.Utils;

namespace TDSClicker.UI.Menus.Changelog;

public partial class ChangelogUi : MenuBase
{
	[Export] public RichTextLabel InfoText { get; set; }
	[Export] public ScrollContainer InfoContainer { get; set; }
	[Export] public Node ArticleButtons { get; set; }
	[Export] public Button GoToTopButton { get; set; }
	[Export] public Control ChangeLogRoot { get; set; }
	[Export] private Tween InfoContainerTween { get; set; }
	
	[Export] private ChangelogLogic _changelogLogic;

	public override void _Ready()
	{
		base._Ready();
		_changelogLogic.OnGetArticlesFinished += _onGetArticlesFinished;
	}

	public override void _ExitTree()
	{
		base._ExitTree();
		_changelogLogic.OnGetArticlesFinished -= _onGetArticlesFinished;
	}

	private void _onGetArticlesFinished()
	{
		foreach (var child in ArticleButtons.GetChildren())
		{
			child.QueueFree();
		}


		foreach (var article in _changelogLogic.Articles)
		{
			var button = ObjectHelper.Create<Button>("ChangelogArticleButton", Vector2.Zero, ArticleButtons.GetPath());
			button.Text = Tr(article.Name);
			button.Pressed += () => _onArticleButtonClicked(article);
		}
	}

	private void _onArticleButtonClicked(ChangeLogData article)
	{
		_switchArticle(article);
	}

	private async void _switchArticle(ChangeLogData article)
	{
		if (GameManager.Settings.UiAnimations)
		{
			InfoContainerTween?.Kill();
			InfoContainerTween = CreateTween();
			InfoContainerTween.SetTrans(Tween.TransitionType.Quad);
		
			InfoContainerTween.Parallel().TweenProperty(InfoContainer, "modulate:a", 0, 0.15f);
			InfoContainerTween.Parallel().TweenProperty(InfoContainer, "position:x", 180, 0.2f);
		
			await ToSignal(InfoContainerTween, Tween.SignalName.Finished);
		
			InfoContainerTween?.Kill();
			InfoContainerTween = CreateTween();
			InfoContainerTween.SetTrans(Tween.TransitionType.Quad);
			InfoContainerTween.Parallel().TweenProperty(InfoContainer, "modulate:a", 1, 0.2f);
			InfoContainerTween.Parallel().TweenProperty(InfoContainer, "position:x", 164.0, 0.3f);
		}
		InfoText.Text = article.GetLocalizedText();
		InfoContainer.ScrollVertical = 0;	

	}
}
