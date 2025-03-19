import 'dart:convert';

// TODO: Use tuple once Parchment is ported to Dart 3
List<int> toRGBA(int colorValue) {
  return [
    (0xff000000 & colorValue) >> 24,
    (0x00ff0000 & colorValue) >> 16,
    (0x0000ff00 & colorValue) >> 8,
    (0x000000ff & colorValue) >> 0
  ];
}

int colorValueFromCSS(String cssColor) {
  // https://developer.mozilla.org/docs/Web/CSS/color_value/rgb
  if (cssColor.startsWith('rgba(') || cssColor.startsWith('rgb(')) {
    var split = _chooseSplit(cssColor);

    final hasAlpha = split.length == 4;
    final components = <int>[];
    for (var i = 0; i < split.length; i++) {
      var s = split[i];
      s = s.trim();
      s = s.replaceFirst('rgba(', '');
      s = s.replaceFirst('rgb(', '');
      s = s.replaceFirst(')', '');
      if (hasAlpha && i == 3) {
        if (s.endsWith('%')) {
          components.add(int.parse(s.split('%')[0]));
        } else {
          final rawValue = double.parse(s);
          if (rawValue > 1.0 || rawValue < 0) {
            throw ArgumentError('Alpha component must be between 0.0 and 1.0');
          }
          components.add((rawValue * 255).floor());
        }
      } else {
        components.add(int.parse(s));
      }
    }
    return (((components.length == 4 ? components[3] : 255 & 0xff) << 24) |
            ((components[0] & 0xff) << 16) |
            ((components[1] & 0xff) << 8) |
            ((components[2] & 0xff) << 0)) &
        0xFFFFFFFF;
  }

  // https://developer.mozilla.org/en-US/docs/Web/CSS/hex-color
  if (cssColor.startsWith('#')) {
    String sHexValue = cssColor.split('#')[1];
    if (sHexValue.length == 3) {
      String r = sHexValue[0];
      String g = sHexValue[1];
      String b = sHexValue[2];
      sHexValue = 'FF$r$r$g$g$b$b';
    } else if (sHexValue.length == 4) {
      String r = sHexValue[0];
      String g = sHexValue[1];
      String b = sHexValue[2];
      String a = sHexValue[3];
      sHexValue = '$a$a$r$r$g$g$b$b';
    } else if (sHexValue.length == 6) {
      sHexValue = 'FF$sHexValue';
    } else if (sHexValue.length == 8) {
      sHexValue = sHexValue.substring(6, 8) + sHexValue.substring(0, 6);
    } else {
      throw ArgumentError('Invalid hex value $cssColor');
    }
    return int.parse(sHexValue, radix: 16);
  }
  // hsl() not supported for the time being
  // throw ArgumentError('Unsupported CSS color format : $cssColor');
  const Map<String, String> htmlColors = {
    "aliceblue": "#F0F8FF",
    "antiquewhite": "#FAEBD7",
    "aqua": "#00FFFF",
    "aquamarine": "#7FFFD4",
    "azure": "#F0FFFF",
    "beige": "#F5F5DC",
    "bisque": "#FFE4C4",
    "black": "#000000",
    "blanchedalmond": "#FFEBCD",
    "blue": "#0000FF",
    "blueviolet": "#8A2BE2",
    "brown": "#A52A2A",
    "burlywood": "#DEB887",
    "cadetblue": "#5F9EA0",
    "chartreuse": "#7FFF00",
    "chocolate": "#D2691E",
    "coral": "#FF7F50",
    "cornflowerblue": "#6495ED",
    "cornsilk": "#FFF8DC",
    "crimson": "#DC143C",
    "cyan": "#00FFFF",
    "darkblue": "#00008B",
    "darkcyan": "#008B8B",
    "darkgoldenrod": "#B8860B",
    "darkgray": "#A9A9A9",
    "darkgrey": "#A9A9A9",
    "darkgreen": "#006400",
    "darkkhaki": "#BDB76B",
    "darkmagenta": "#8B008B",
    "darkolivegreen": "#556B2F",
    "darkorange": "#FF8C00",
    "darkorchid": "#9932CC",
    "darkred": "#8B0000",
    "darksalmon": "#E9967A",
    "darkseagreen": "#8FBC8F",
    "darkslateblue": "#483D8B",
    "darkslategray": "#2F4F4F",
    "darkslategrey": "#2F4F4F",
    "darkturquoise": "#00CED1",
    "darkviolet": "#9400D3",
    "deeppink": "#FF1493",
    "deepskyblue": "#00BFFF",
    "dimgray": "#696969",
    "dimgrey": "#696969",
    "dodgerblue": "#1E90FF",
    "firebrick": "#B22222",
    "floralwhite": "#FFFAF0",
    "forestgreen": "#228B22",
    "fuchsia": "#FF00FF",
    "gainsboro": "#DCDCDC",
    "ghostwhite": "#F8F8FF",
    "gold": "#FFD700",
    "goldenrod": "#DAA520",
    "gray": "#808080",
    "grey": "#808080",
    "green": "#008000",
    "greenyellow": "#ADFF2F",
    "honeydew": "#F0FFF0",
    "hotpink": "#FF69B4",
    "indianred": "#CD5C5C",
    "indigo": "#4B0082",
    "ivory": "#FFFFF0",
    "khaki": "#F0E68C",
    "lavender": "#E6E6FA",
    "lavenderblush": "#FFF0F5",
    "lawngreen": "#7CFC00",
    "lemonchiffon": "#FFFACD",
    "lightblue": "#ADD8E6",
    "lightcoral": "#F08080",
    "lightcyan": "#E0FFFF",
    "lightgoldenrodyellow": "#FAFAD2",
    "lightgray": "#D3D3D3",
    "lightgrey": "#D3D3D3",
    "lightgreen": "#90EE90",
    "lightpink": "#FFB6C1",
    "lightsalmon": "#FFA07A",
    "lightseagreen": "#20B2AA",
    "lightskyblue": "#87CEFA",
    "lightslategray": "#778899",
    "lightslategrey": "#778899",
    "lightsteelblue": "#B0C4DE",
    "lightyellow": "#FFFFE0",
    "lime": "#00FF00",
    "limegreen": "#32CD32",
    "linen": "#FAF0E6",
    "magenta": "#FF00FF",
    "maroon": "#800000",
    "mediumaquamarine": "#66CDAA",
    "mediumblue": "#0000CD",
    "mediumorchid": "#BA55D3",
    "mediumpurple": "#9370DB",
    "mediumseagreen": "#3CB371",
    "mediumslateblue": "#7B68EE",
    "mediumspringgreen": "#00FA9A",
    "mediumturquoise": "#48D1CC",
    "mediumvioletred": "#C71585",
    "midnightblue": "#191970",
    "mintcream": "#F5FFFA",
    "mistyrose": "#FFE4E1",
    "moccasin": "#FFE4B5",
    "navajowhite": "#FFDEAD",
    "navy": "#000080",
    "oldlace": "#FDF5E6",
    "olive": "#808000",
    "olivedrab": "#6B8E23",
    "orange": "#FFA500",
    "orangered": "#FF4500",
    "orchid": "#DA70D6",
    "palegoldenrod": "#EEE8AA",
    "palegreen": "#98FB98",
    "paleturquoise": "#AFEEEE",
    "palevioletred": "#DB7093",
    "papayawhip": "#FFEFD5",
    "peachpuff": "#FFDAB9",
    "peru": "#CD853F",
    "pink": "#FFC0CB",
    "plum": "#DDA0DD",
    "powderblue": "#B0E0E6",
    "purple": "#800080",
    "red": "#FF0000",
    "rosybrown": "#BC8F8F",
    "royalblue": "#4169E1",
    "saddlebrown": "#8B4513",
    "salmon": "#FA8072",
    "sandybrown": "#F4A460",
    "seagreen": "#2E8B57",
    "seashell": "#FFF5EE",
    "sienna": "#A0522D",
    "silver": "#C0C0C0",
    "skyblue": "#87CEEB",
    "slateblue": "#6A5ACD",
    "slategray": "#708090",
    "slategrey": "#708090",
    "snow": "#FFFAFA",
    "springgreen": "#00FF7F",
    "steelblue": "#4682B4",
    "tan": "#D2B48C",
    "teal": "#008080",
    "thistle": "#D8BFD8",
    "tomato": "#FF6347",
    "turquoise": "#40E0D0",
    "violet": "#EE82EE",
    "wheat": "#F5DEB3",
    "white": "#FFFFFF",
    "whitesmoke": "#F5F5F5",
    "yellow": "#FFFF00",
    "yellowgreen": "#9ACD32"
  };

  if(htmlColors.containsKey(cssColor.toLowerCase())) {
    return colorValueFromCSS(htmlColors[cssColor.toLowerCase()]!);
  }

  return 0xffffffff;
}

List<String> _chooseSplit(String cssColor) {
  var split = cssColor.split(',');

  // it's rgb(r,g,b[,a])
  if (split.length >= 3) return split;

  // it's rgb(r g b [/ a])
  split = cssColor.split(' ');
  if (split.length < 3) {
    throw ArgumentError(
        'CSS color - rgb(a) must have at least 3 components. Received $cssColor');
  }

  final clean = <String>[];
  bool hasSlash = false;
  for (var s in split) {
    s = s.trim();
    if (s == '/') {
      hasSlash = true;
      continue;
    }
    if (s.isNotEmpty) {
      clean.add(s);
    }
  }
  if (hasSlash && clean.length != 4) {
    throw ArgumentError(
        'CSS color - expected 4 components. Received $cssColor');
  }
  if (!hasSlash && clean.length != 3) {
    throw ArgumentError(
        'CSS color : expecting 3 components. Received $cssColor');
  }
  return clean;
}
