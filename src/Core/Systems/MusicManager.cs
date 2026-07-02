using Godot;
using System.Collections.Generic;
namespace TDSClicker.Core.Systems;

public partial class MusicManager : Node2D
{
	public static MusicManager Instance { get; private set; }
	
	private List<AudioStream> _tracks;
	[Export] public AudioStreamPlayer Player;

	public override void _Ready()
	{
		Player ??= GetNode<AudioStreamPlayer>("music");
		_rng.Randomize();
		_tracks = GetTracks();
		Player.Connect("finished", new Callable(this, nameof(OnMusicFinished)));
		
		PlayMusic();
	}

	private static List<AudioStream> GetTracks()
	{
		var tracks = new List<AudioStream>();

		using var dir = DirAccess.Open("res://Assets/Music/");
		dir.ListDirBegin();

		var fileName = dir.GetNext();

		while (fileName != "")
		{
			if (fileName.EndsWith(".ogg"))
			{
				var path = "res://Assets/Music/" + fileName;
				var item = GD.Load<AudioStream>(path);

				tracks.Add(item);
			}

			fileName = dir.GetNext();
		}

		dir.ListDirEnd();
		return tracks;
	}

	private RandomNumberGenerator _rng = new();

	public void PlayMusic()
	{
		if (_tracks.Count == 0) return;

		var index = _rng.RandiRange(0, _tracks.Count - 1);
		var stream = _tracks[index];

		Player.Stream = stream;
		Player.Play();
	}

	public void ResetMusic()
	{
		Player.Stop();
		_tracks = GetTracks();
		PlayMusic();
	}

	public void OnMusicFinished()
	{
		PlayMusic();
	}
}
