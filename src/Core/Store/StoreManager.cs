using Godot;
using System.Collections.Generic;
using System.Linq;

namespace TDSClicker.Core.Store;

public partial class StoreManager : Node
{
    public static StoreManager Instance { get; private set; }

    public List<Resource> StoreItems = new();
    
    public Dictionary<string, StoreData> UpgradeData = new();
    public List<Resource> UpgradeItems = new();
    
    public Dictionary<string, Control> UpgradeContainers = new();
    
    public StoreData CurrentItem;

    [Signal] public delegate void LoadingFinishedEventHandler();

    
    private List<string> _folders = new List<string>();
    
    public override void _Ready()
    {
        Instance = this;
        
        _StartLoading();   
        
        CallDeferred(nameof(EmitLoadingFinished));
    }

    private void EmitLoadingFinished() => EmitSignal(SignalName.LoadingFinished);
    
    private void _StartLoading()
    {
        _folders.Add("res://Resources/Store/Enemies/");
        _folders.Add("res://Resources/Store/Droopers/");
        _folders.Add("res://Resources/Store/Upgrades/");

        foreach (var folder in _folders)
        {
            var items = _EnumerateStoreItems(folder);
            StoreItems.AddRange(items);
        }
    }

    private List<string> _items = new List<string>();
    
    private static List<Resource> _EnumerateStoreItems(string folder)
    {
        var result = new List<Resource>();
        using var dir = DirAccess.Open(folder);

        dir.ListDirBegin();

        var fileName = dir.GetNext();
        
        while (fileName != "")
        {
            if (fileName.EndsWith(".tres"))
            {
                var path = folder + fileName;
                var item = GD.Load<Resource>(path);
                result.Add(item);
            }

            fileName = dir.GetNext();
        }

        dir.ListDirEnd();
        
        result = result
            .OrderBy(r => (r as StoreData)?.Price ?? 0)
            .ToList();
        
        return result;
    }
}