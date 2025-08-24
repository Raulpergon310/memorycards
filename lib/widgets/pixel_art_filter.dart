import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class PixelArtFilter extends StatelessWidget {
  final Widget child;
  final double pixelSize;

  const PixelArtFilter({
    Key? key,
    required this.child,
    this.pixelSize = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: PixelArtPainter(pixelSize: pixelSize),
        child: child,
      ),
    );
  }
}

class PixelArtPainter extends CustomPainter {
  final double pixelSize;

  PixelArtPainter({required this.pixelSize});

  @override
  void paint(Canvas canvas, Size size) {
    // This painter doesn't draw anything - it's just to trigger repaints
    // The actual pixelation is done using a different approach
  }

  @Override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Alternative approach using ImageFiltered
class PixelArtFilterWidget extends StatelessWidget {
  final Widget child;
  final double pixelSize;

  const PixelArtFilterWidget({
    Key? key,
    required this.child,
    this.pixelSize = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final downsampledWidth = (screenSize.width / pixelSize).floor();
    final downsampledHeight = (screenSize.height / pixelSize).floor();

    return RepaintBoundary(
      child: Transform.scale(
        scale: 1.0,
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.matrix(
              Float64List.fromList([
                pixelSize, 0, 0, 0,
                0, pixelSize, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1,
              ]),
            ),
            child: Transform.scale(
              scale: 1.0 / pixelSize,
              child: Container(
                width: screenSize.width * pixelSize,
                height: screenSize.height * pixelSize,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Simpler pixel effect using low resolution rendering
class RetroPixelFilter extends StatelessWidget {
  final Widget child;
  final double scale;

  const RetroPixelFilter({
    Key? key,
    required this.child,
    this.scale = 0.3, // Lower values = more pixelated
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Transform.scale(
        scale: 1.0 / scale,
        child: Transform.scale(
          scale: scale,
          filterQuality: FilterQuality.none, // Disable smooth scaling
          child: child,
        ),
      ),
    );
  }
}

// Matrix-based pixelation filter
class PixelMatrixFilter extends StatelessWidget {
  final Widget child;
  final int pixelSize;

  const PixelMatrixFilter({
    Key? key,
    required this.child,
    this.pixelSize = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PixelGridPainter(pixelSize: pixelSize),
      child: ClipRect(
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.matrix(
            _createPixelationMatrix(pixelSize.toDouble()),
          ),
          child: child,
        ),
      ),
    );
  }

  Float64List _createPixelationMatrix(double size) {
    return Float64List.fromList([
      1/size, 0, 0, 0,
      0, 1/size, 0, 0, 
      0, 0, 1, 0,
      0, 0, 0, 1,
    ]);
  }
}

class PixelGridPainter extends CustomPainter {
  final int pixelSize;

  PixelGridPainter({required this.pixelSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Optional: Draw pixel grid overlay
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (int i = 0; i < size.width; i += pixelSize) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    // Draw horizontal lines  
    for (int i = 0; i < size.height; i += pixelSize) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}