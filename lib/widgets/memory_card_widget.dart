import 'package:flutter/material.dart';
import '../models/memory_card.dart';

class MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final bool isFlipped;
  final VoidCallback onFlip;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const MemoryCardWidget({
    Key? key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  }) : super(key: key);

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onFlip,
          onPanEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx > 200) {
              widget.onSwipeRight();
            } else if (details.velocity.pixelsPerSecond.dx < -200) {
              widget.onSwipeLeft();
            }
          },
          child: Container(
            width: 320,
            height: 200,
            margin: const EdgeInsets.all(16),
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final isShowingFront = _flipAnimation.value < 0.5;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_flipAnimation.value * 3.14159),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isShowingFront
                            ? [Colors.blue.shade400, Colors.purple.shade400]
                            : [Colors.pink.shade400, Colors.red.shade400],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateY(isShowingFront ? 0 : 3.14159),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            isShowingFront ? widget.card.front : widget.card.back,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              onPressed: widget.onSwipeLeft,
              heroTag: "prev",
              backgroundColor: Colors.pink.shade300,
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            FloatingActionButton(
              onPressed: widget.onFlip,
              heroTag: "flip",
              backgroundColor: Colors.blue.shade400,
              child: Icon(
                widget.isFlipped ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
            ),
            FloatingActionButton(
              onPressed: widget.onSwipeRight,
              heroTag: "next",
              backgroundColor: Colors.teal.shade300,
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}