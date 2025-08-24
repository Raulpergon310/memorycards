import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/memory_card.dart';
import '../widgets/memory_card_widget.dart';
import '../theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  final Deck deck;

  const GameScreen({Key? key, required this.deck}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentCardIndex = 0;
  bool _isFlipped = false;
  List<MemoryCard> _shuffledCards = [];

  @override
  void initState() {
    super.initState();
    _shuffleCards();
  }

  void _shuffleCards() {
    setState(() {
      _shuffledCards = List.from(widget.deck.cards);
      _shuffledCards.shuffle();
      _currentCardIndex = 0;
      _isFlipped = false;
    });
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard() {
    if (_currentCardIndex < _shuffledCards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isFlipped = false;
      });
    }
  }

  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _isFlipped = false;
      });
    }
  }

  void _restartGame() {
    setState(() {
      _currentCardIndex = 0;
      _isFlipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deck.cards.isEmpty) {
      return Scaffold(
        body: Container(
          color: AppTheme.lightWoodBrown,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: AppTheme.getCardDecoration(),
                    child: Column(
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: 80,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Esta baraja no tiene cartas aún',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: AppTheme.getCardDecoration(),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            color: AppTheme.textDark,
                            iconSize: 32,
                            tooltip: 'Volver',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final currentCard = _shuffledCards[_currentCardIndex];
    final progress = (_currentCardIndex + 1) / _shuffledCards.length;
    final isLastCard = _currentCardIndex == _shuffledCards.length - 1;

    return Scaffold(
      body: Container(
        color: AppTheme.lightWoodBrown,
        child: SafeArea(
          child: Column(
            children: [
              // Custom header with actions
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: AppTheme.getCardDecoration(),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        color: AppTheme.textDark,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: AppTheme.getCardDecoration(),
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        onPressed: _shuffleCards,
                        icon: const Icon(Icons.shuffle),
                        color: AppTheme.textDark,
                      ),
                    ),
                    Container(
                      decoration: AppTheme.getCardDecoration(),
                      child: IconButton(
                        onPressed: _restartGame,
                        icon: const Icon(Icons.refresh),
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'Carta ${_currentCardIndex + 1} de ${_shuffledCards.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.darkWoodBrown,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.shadowBrown,
                          width: 1,
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.cardYellow,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Card display
              Expanded(
                child: Center(
                  child: MemoryCardWidget(
                    cards: _shuffledCards,
                    currentIndex: _currentCardIndex,
                    isFlipped: _isFlipped,
                    onFlip: _flipCard,
                    onSwipeLeft: _previousCard,
                    onSwipeRight: _nextCard,
                  ),
                ),
              ),
              // Visual hints for gestures
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Gesture hints
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            color: AppTheme.textLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Toca • Arrastra',
                              style: AppTheme.getPixelTextStyle(
                                fontSize: 12,
                                color: AppTheme.textLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLastCard) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.getCardDecoration(),
                        child: Column(
                          children: [
                            Text(
                              '¡Has llegado al final de la baraja!',
                              style: AppTheme.getPixelTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  decoration: AppTheme.getCardDecoration(),
                                  child: IconButton(
                                    onPressed: _restartGame,
                                    icon: const Icon(Icons.refresh),
                                    color: AppTheme.textDark,
                                    iconSize: 32,
                                    tooltip: 'Reiniciar',
                                  ),
                                ),
                                Container(
                                  decoration: AppTheme.getCardDecoration(),
                                  child: IconButton(
                                    onPressed: _shuffleCards,
                                    icon: const Icon(Icons.shuffle),
                                    color: AppTheme.textDark,
                                    iconSize: 32,
                                    tooltip: 'Barajar',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}