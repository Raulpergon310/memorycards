import 'package:flutter/material.dart';

class AppTheme {
  // Pixel art wooden theme colors - pastel tones
  static const Color woodenBrown = Color(0xFFD4A574);
  static const Color darkWoodBrown = Color(0xFFA67C52);
  static const Color lightWoodBrown = Color(0xFFE8C4A0);
  static const Color cardYellow = Color(0xFFFFF4A3);
  static const Color darkCardYellow = Color(0xFFE6D584);
  static const Color lightCardYellow = Color(0xFFFFFBCC);
  static const Color shadowBrown = Color(0xFF8B5E34);
  static const Color textDark = Color(0xFF5D4037);
  static const Color textLight = Color(0xFF8D6E63);
  
  static ThemeData get pixelWoodTheme {
    return ThemeData(
      fontFamily: 'monospace', // Monospace font for pixel art feel
      useMaterial3: false,
      primaryColor: woodenBrown,
      scaffoldBackgroundColor: lightWoodBrown,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: woodenBrown,
        onPrimary: Colors.white,
        secondary: cardYellow,
        onSecondary: textDark,
        error: Color(0xFFB71C1C),
        onError: Colors.white,
        background: lightWoodBrown,
        onBackground: textDark,
        surface: woodenBrown,
        onSurface: textDark,
      ),
      cardTheme: CardTheme(
        color: cardYellow,
        shadowColor: shadowBrown.withOpacity(0.3),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Sharp corners for pixel art
          side: BorderSide(
            color: darkCardYellow,
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: woodenBrown,
          foregroundColor: Colors.white,
          elevation: 0, // No elevation for pixel art
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Sharp corners
            side: BorderSide(
              color: darkWoodBrown,
              width: 2,
            ),
          ),
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.0,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkWoodBrown,
        foregroundColor: Colors.white,
        elevation: 0, // No elevation for pixel art
        shadowColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
          letterSpacing: 1.0,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: 1.0,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: 1.0,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'monospace',
          color: textDark,
          letterSpacing: 1.0,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'monospace',
          color: textDark,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
  
  // Pixel art card decoration
  static BoxDecoration getCardDecoration({
    Color? backgroundColor,
    bool isStacked = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? cardYellow,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: darkCardYellow,
        width: 3,
      ),
      boxShadow: [
        if (isStacked) ...[
          BoxShadow(
            color: shadowBrown.withOpacity(0.4),
            offset: const Offset(4, 4),
            blurRadius: 0, // No blur for pixel art
          ),
          BoxShadow(
            color: shadowBrown.withOpacity(0.2),
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ] else
          BoxShadow(
            color: shadowBrown.withOpacity(0.4),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
      ],
    );
  }
  
  // Add button decoration (card outline with plus)
  static BoxDecoration getAddButtonDecoration() {
    return BoxDecoration(
      color: lightWoodBrown,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: darkWoodBrown,
        width: 3,
        style: BorderStyle.solid,
      ),
      boxShadow: [
        BoxShadow(
          color: shadowBrown.withOpacity(0.4),
          offset: const Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    );
  }
  
  // Pixel art dashed border widget
  static Widget getPixelDashedBorder(Widget child) {
    return CustomPaint(
      painter: PixelDashedBorderPainter(),
      child: Container(
        margin: const EdgeInsets.all(2),
        child: child,
      ),
    );
  }
  
  // Pixel art text style
  static TextStyle getPixelTextStyle({
    double fontSize = 16,
    Color color = textDark,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      fontFamily: 'monospace', // Use system monospace
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: 1.2, // Tighter line height for pixel feel
      letterSpacing: 1.0, // Slight letter spacing for pixelated look
    );
  }
}

// Custom painter for pixel art dashed borders
class PixelDashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.darkWoodBrown
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;
    
    // Top border
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset((startX + dashWidth).clamp(0, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
    
    // Bottom border
    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset((startX + dashWidth).clamp(0, size.width), size.height),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
    
    // Left border
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, (startY + dashWidth).clamp(0, size.height)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
    
    // Right border
    startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width, (startY + dashWidth).clamp(0, size.height)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}