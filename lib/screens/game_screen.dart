import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/memory_card.dart';
import '../widgets/memory_card_widget.dart';

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
        appBar: AppBar(
          title: Text(widget.deck.name),
          backgroundColor: Colors.blue.shade400,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.style_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta baraja no tiene cartas aún',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver a gestionar barajas'),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _shuffledCards[_currentCardIndex];
    final progress = (_currentCardIndex + 1) / _shuffledCards.length;
    final isLastCard = _currentCardIndex == _shuffledCards.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.name),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _shuffleCards,
            icon: const Icon(Icons.shuffle),
            tooltip: 'Barajar cartas',
          ),
          IconButton(
            onPressed: _restartGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reiniciar',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Carta ${_currentCardIndex + 1} de ${_shuffledCards.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: MemoryCardWidget(
                  card: currentCard,
                  isFlipped: _isFlipped,
                  onFlip: _flipCard,
                  onSwipeLeft: _previousCard,
                  onSwipeRight: _nextCard,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _currentCardIndex > 0 ? _previousCard : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Anterior'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade300,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _flipCard,
                        icon: Icon(_isFlipped 
                            ? Icons.visibility_off 
                            : Icons.visibility),
                        label: Text(_isFlipped ? 'Ver Pregunta' : 'Ver Respuesta'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _currentCardIndex < _shuffledCards.length - 1 
                            ? _nextCard 
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Siguiente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade300,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (isLastCard) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '¡Has llegado al final de la baraja!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: _restartGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade400,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Reiniciar'),
                              ),
                              ElevatedButton(
                                onPressed: _shuffleCards,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade400,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Barajar y Reiniciar'),
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
    );
  }
}