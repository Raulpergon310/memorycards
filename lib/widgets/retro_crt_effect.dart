import 'package:flutter/material.dart';
import 'dart:math' as math;

class RetroCRTEffect extends StatefulWidget {
  final Widget child;
  final bool enableScanlines;
  final bool enablePixelation;
  final bool enableVignette;
  final double pixelScale;

  const RetroCRTEffect({
    Key? key,
    required this.child,
    this.enableScanlines = true,
    this.enablePixelation = true,
    this.enableVignette = true,
    this.pixelScale = 0.6,
  }) : super(key: key);

  @override
  State<RetroCRTEffect> createState() => _RetroCRTEffectState();
}

class _RetroCRTEffectState extends State<RetroCRTEffect>
    with TickerProviderStateMixin {
  late AnimationController _scanlineController;
  late Animation<double> _scanlineAnimation;

  @override
  void initState() {
    super.initState();
    _scanlineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scanlineAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_scanlineController);
    
    if (widget.enableScanlines) {
      _scanlineController.repeat();
    }
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = widget.child;

    // Apply pixelation effect
    if (widget.enablePixelation) {
      result = Transform.scale(
        scale: 1.0 / widget.pixelScale,
        child: Transform.scale(
          scale: widget.pixelScale,
          filterQuality: FilterQuality.none,
          child: result,
        ),
      );
    }

    // Apply CRT effects
    result = Stack(
      children: [
        result,
        
        // Scanlines overlay
        if (widget.enableScanlines)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _scanlineAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScanlinesPainter(
                    animationValue: _scanlineAnimation.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        
        // Vignette effect
        if (widget.enableVignette)
          IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color.fromRGBO(0, 0, 0, 0.3),
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),
      ],
    );

    return RepaintBoundary(child: result);
  }
}

class ScanlinesPainter extends CustomPainter {
  final double animationValue;
  static const double scanlineHeight = 2.0;
  static const double scanlineSpacing = 4.0;

  const ScanlinesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = scanlineHeight;

    // Static scanlines
    for (double y = 0; y < size.height; y += scanlineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Moving scanline for CRT effect
    final movingScanlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.0;

    final movingY = size.height * animationValue;
    canvas.drawLine(
      Offset(0, movingY),
      Offset(size.width, movingY),
      movingScanlinePaint,
    );
    
    // Add some random flicker lines
    final random = math.Random(42); // Fixed seed for consistency
    final flickerPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;
      
    for (int i = 0; i < 3; i++) {
      final flickerY = random.nextDouble() * size.height;
      if ((animationValue * 100).floor() % (i + 2) == 0) {
        canvas.drawLine(
          Offset(0, flickerY),
          Offset(size.width, flickerY),
          flickerPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ScanlinesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// RGB separation effect for extra retro feel
class RGBSeparationPainter extends CustomPainter {
  final double separation;

  const RGBSeparationPainter({this.separation = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    // This would require custom shaders or more complex rendering
    // For now, we'll use a simple overlay approach
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}