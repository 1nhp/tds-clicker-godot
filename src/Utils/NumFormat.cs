using System.Globalization;
namespace TDSClicker.Utils;

public static class NumFormat
{
    private static readonly (double Value, string Suffix)[] Suffixes =
    {
        (1e13, "S"),
        (1e12, "Qt"),
        (1e11, "Q"),
        (1e10, "T"),
        (1e9, "B"),
        (1e6, "M"),
        (1e3, "K")
    };

    public static string FormatNumber(double number)
    {
        foreach (var (value, suffix) in Suffixes)
        {
            if (number >= value)
                return (number / value).ToString("0.##", CultureInfo.InvariantCulture) + suffix;
        }

        return ((int)number).ToString(CultureInfo.InvariantCulture);
    }
}