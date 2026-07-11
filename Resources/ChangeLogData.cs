using Godot;
using Godot.Collections;

[GlobalClass]
public partial class ChangeLogData : Resource
{
    [Export] public string Name { get; set; }
    [Export(PropertyHint.MultilineText)] public string TextEn { get; set; }
    [Export(PropertyHint.MultilineText)] public string TextRu { get; set; }
    
    public string GetLocalizedText()
    {
        var locale = TranslationServer.GetLocale();

        return locale switch
        {
            var l when l.StartsWith("Ru") => !string.IsNullOrEmpty(TextRu) ? TextRu : TextEn,
            _ => TextEn,
        };
    }
}