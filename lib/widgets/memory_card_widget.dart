import 'package:flutter/material.dart';
import '../models/memory_card.dart';
import '../theme/app_theme.dart';

class MemoryCardWidget extends StatefulWidget {
  final List<MemoryCard> cards; // Stack of cards
  final int currentIndex; // Current card index
  final bool isFlipped;
  final VoidCallback onFlip;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const MemoryCardWidget({
    Key? key,
    required this.cards,
    required this.currentIndex,
    required this.isFlipped,
    required this.onFlip,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  }) : super(key: key);

  MemoryCard get currentCard => cards[currentIndex];

  @override
  State<MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<MemoryCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _dragController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _dragAnimation;
  
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _dragController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize drag animation properly at zero
    _dragAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.elasticOut,
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
    
    // ALWAYS reset drag state when card changes - this is crucial
    if (widget.currentIndex != oldWidget.currentIndex) {
      print('🔄 CARD CHANGED!');
      print('   Old index: ${oldWidget.currentIndex}');
      print('   New index: ${widget.currentIndex}');
      print('   Old card: ${oldWidget.currentCard.id}');
      print('   New card: ${widget.currentCard.id}');
      _resetCardPosition();
      _isDragging = false;
      print('   Reset complete');
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    print('🟢 PAN START - Card ID: ${widget.currentCard.id}');
    print('   Current offset: $_dragOffset');
    print('   isDragging: $_isDragging -> true');
    _isDragging = true;
    _dragController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDragging) {
      setState(() {
        _dragOffset += details.delta;
      });
      if (_dragOffset.dx.abs() > 50) { // Solo print cada 50px para no saturar
        print('🔄 PAN UPDATE - Card ID: ${widget.currentCard.id}');
        print('   Delta: ${details.delta}');
        print('   Current offset: $_dragOffset');
      }
    } else {
      print('⚠️ PAN UPDATE IGNORED - isDragging: false');
    }
  }

  void _onPanEnd(DragEndDetails details) {
    print('🔴 PAN END - Card ID: ${widget.currentCard.id}');
    print('   isDragging: $_isDragging');
    print('   Current offset: $_dragOffset');
    
    if (!_isDragging) {
      print('⚠️ PAN END IGNORED - isDragging: false');
      return;
    }
    
    _isDragging = false;
    
    // Check if the card was swiped far enough
    const swipeThreshold = 100.0;
    final velocity = details.velocity.pixelsPerSecond;
    final dx = _dragOffset.dx;
    
    print('   Velocity: ${velocity.dx}');
    print('   Distance: $dx');
    print('   Threshold check: ${dx.abs()} > $swipeThreshold = ${dx.abs() > swipeThreshold}');
    print('   Velocity check: ${velocity.dx.abs()} > 800 = ${velocity.dx.abs() > 800}');
    
    if (dx.abs() > swipeThreshold || velocity.dx.abs() > 800) {
      if (dx > 0 || velocity.dx > 0) {
        print('📱 SWIPE RIGHT detected');
        // Swipe right - next card
        _animateCardExit(true, () {
          // Reset position immediately and then trigger card change
          print('✅ Exit animation complete - calling onSwipeRight');
          _resetCardPosition();
          widget.onSwipeRight();
        });
      } else {
        print('📱 SWIPE LEFT detected');
        // Swipe left - previous card
        _animateCardExit(false, () {
          // Reset position immediately and then trigger card change
          print('✅ Exit animation complete - calling onSwipeLeft');
          _resetCardPosition();
          widget.onSwipeLeft();
        });
      }
    } else {
      print('🔄 RETURN TO CENTER');
      // Return to center
      _animateCardReturn();
    }
  }

  void _resetCardPosition() {
    print('🔄 RESET CARD POSITION');
    print('   Before dragOffset: $_dragOffset');
    print('   Before dragAnimation: ${_dragAnimation.value}');
    
    setState(() {
      _dragOffset = Offset.zero;
    });
    
    // CRITICAL: Reset both the controller AND recreate the animation at zero
    _dragController.reset();
    _dragAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.elasticOut,
    ));
    
    print('   After dragOffset: $_dragOffset');
    print('   After dragAnimation: ${_dragAnimation.value}');
  }

  void _animateCardExit(bool toRight, VoidCallback onComplete) {
    final targetOffset = Offset(toRight ? 400 : -400, 0);
    
    print('🚀 ANIMATE CARD EXIT');
    print('   Direction: ${toRight ? "RIGHT" : "LEFT"}');
    print('   From: $_dragOffset');
    print('   To: $targetOffset');
    
    _dragController.reset();
    _dragAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.easeOut,
    ));
    
    _dragController.forward().then((_) {
      print('🎯 Exit animation completed');
      onComplete();
    });
  }

  void _animateCardReturn() {
    print('↩️ ANIMATE CARD RETURN');
    print('   From: $_dragOffset');
    print('   To: Offset.zero');
    
    final startOffset = _dragOffset;
    
    // CRITICAL: Reset dragOffset immediately when starting return animation
    setState(() {
      _dragOffset = Offset.zero;
    });
    
    _dragController.reset();
    _dragAnimation = Tween<Offset>(
      begin: startOffset, // Use saved start position
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dragController,
      curve: Curves.elasticOut,
    ));
    
    _dragController.forward().then((_) {
      print('✅ Return animation completed');
      // dragOffset is already zero, just reset the animation
      _dragController.reset();
      _dragAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _dragController,
        curve: Curves.elasticOut,
      ));
      print('   Final dragOffset: $_dragOffset');
      print('   Final dragAnimation: ${_dragAnimation.value}');
    });
  }

  Widget _buildCard(MemoryCard card, {
    required double offsetX,
    required double offsetY,
    required double scale,
    required double rotation,
    required bool isInteractive,
    bool isFlipped = false,
  }) {
    return Transform.translate(
      offset: Offset(offsetX, offsetY),
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            width: 300,
            height: 180,
            margin: const EdgeInsets.all(16),
            child: isInteractive ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value * 3.14159),
              child: _buildCardContent(card, _flipAnimation.value < 0.5 ? card.front : card.back),
            ) : _buildCardContent(card, card.front), // Static cards show front
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(MemoryCard card, String text) {
    return Container(
      decoration: AppTheme.getCardDecoration(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            text,
            style: AppTheme.getPixelTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const maxVisibleCards = 3;
    
    return Column(
      children: [
        // Card stack
        Container(
          height: 250, // Fixed height for the stack
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Background cards (upcoming cards) - render in reverse order so current card is on top
              ...List.generate(maxVisibleCards, (stackIndex) {
                final cardIndex = widget.currentIndex + stackIndex;
                
                if (cardIndex >= widget.cards.length) return const SizedBox.shrink();
                
                final card = widget.cards[cardIndex];
                final isCurrentCard = stackIndex == 0;
                
                if (!isCurrentCard) {
                  // Background cards (stacked behind)
                  final depth = stackIndex.toDouble();
                  final cardScale = 1.0 - (depth * 0.05); // Each card 5% smaller
                  final cardOffsetY = depth * 8; // Each card 8px lower
                  final cardOffsetX = depth * 2; // Slight horizontal offset
                  
                  return Positioned(
                    child: _buildCard(
                      card,
                      offsetX: cardOffsetX,
                      offsetY: cardOffsetY,
                      scale: cardScale,
                      rotation: 0,
                      isInteractive: false,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }).reversed.toList(),
              
              // Current draggable card - always on top
              GestureDetector(
                onTap: widget.onFlip,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_flipAnimation, _dragAnimation]),
                  builder: (context, child) {
                    final currentOffset = _isDragging ? _dragOffset : _dragAnimation.value;
                    final isShowingFront = _flipAnimation.value < 0.5;
                    
                    // Debug every frame would be too much, so only when offset is significant
                    if (currentOffset.dx.abs() > 10 || currentOffset.dy.abs() > 10) {
                      print('🎨 BUILD - Card ID: ${widget.currentCard.id}');
                      print('   isDragging: $_isDragging');
                      print('   dragOffset: $_dragOffset');
                      print('   dragAnimation: ${_dragAnimation.value}');
                      print('   currentOffset: $currentOffset');
                    }
                    
                    // Calculate rotation and scale based on drag
                    final rotation = currentOffset.dx * 0.0008;
                    final scale = 1.0 - (currentOffset.dx.abs() * 0.0002);
                    
                    return _buildCard(
                      widget.currentCard,
                      offsetX: currentOffset.dx,
                      offsetY: currentOffset.dy,
                      scale: scale.clamp(0.85, 1.0),
                      rotation: rotation,
                      isInteractive: true,
                      isFlipped: widget.isFlipped,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Visual feedback for gestures
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe_left,
                color: AppTheme.textLight,
                size: 24,
              ),
              const SizedBox(width: 16),
              Container(
                decoration: AppTheme.getCardDecoration(),
                child: IconButton(
                  onPressed: widget.onFlip,
                  icon: Icon(
                    widget.isFlipped ? Icons.visibility_off : Icons.visibility,
                  ),
                  color: AppTheme.textDark,
                  iconSize: 28,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.swipe_right,
                color: AppTheme.textLight,
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }
}