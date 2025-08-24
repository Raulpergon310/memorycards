import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class DeckManagerScreen extends StatefulWidget {
  const DeckManagerScreen({Key? key}) : super(key: key);

  @override
  State<DeckManagerScreen> createState() => _DeckManagerScreenState();
}

class _DeckManagerScreenState extends State<DeckManagerScreen> {
  List<Deck> _decks = [];
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final decks = await _storageService.getDecks();
    setState(() {
      _decks = decks;
    });
  }

  Future<void> _saveDeck(Deck deck) async {
    await _storageService.saveDeck(deck);
    _loadDecks();
  }

  Future<void> _deleteDeck(String deckId) async {
    await _storageService.deleteDeck(deckId);
    _loadDecks();
  }

  void _createNewDeck() {
    final newDeck = Deck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Nueva Baraja',
      description: '',
      cards: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    Navigator.pushNamed(
      context,
      '/create-card',
      arguments: {
        'deck': newDeck,
        'onSave': (Deck updatedDeck) {
          _saveDeck(updatedDeck);
        },
      },
    );
  }

  void _editDeck(Deck deck) {
    Navigator.pushNamed(
      context,
      '/create-card',
      arguments: {
        'deck': deck,
        'onSave': (Deck updatedDeck) {
          _saveDeck(updatedDeck);
        },
      },
    );
  }

  void _playDeck(Deck deck) {
    Navigator.pushNamed(context, '/game', arguments: deck);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    
    // Create items list with decks + add button
    final items = List<Widget>.generate(
      _decks.length + 1,
      (index) {
        if (index == _decks.length) {
          // Add new deck button
          return _buildAddDeckCard();
        }
        return _buildDeckCard(_decks[index]);
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
          children: items,
        ),
        ),
      ),
    );
  }

  Widget _buildDeckCard(Deck deck) {
    return GestureDetector(
      onTap: () => deck.cards.isNotEmpty ? _playDeck(deck) : _editDeck(deck),
      onLongPress: () => _showDeckOptions(deck),
      child: Container(
        decoration: AppTheme.getCardDecoration(isStacked: true),
        child: Stack(
          children: [
            // Stacked card effect - back cards
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              bottom: 8,
              child: Container(
                decoration: AppTheme.getCardDecoration(),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              right: 4,
              bottom: 4,
              child: Container(
                decoration: AppTheme.getCardDecoration(),
              ),
            ),
            // Front card
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: AppTheme.getCardDecoration(),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        deck.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCardYellow,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppTheme.shadowBrown,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${deck.cards.length} cartas',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDeckCard() {
    return GestureDetector(
      onTap: _createNewDeck,
      child: AppTheme.getPixelDashedBorder(
        Container(
          decoration: AppTheme.getAddButtonDecoration(),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 48,
                color: AppTheme.darkWoodBrown,
              ),
              SizedBox(height: 8),
              Text(
                'Nueva\nBaraja',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeckOptions(Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardYellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: AppTheme.darkCardYellow,
            width: 2,
          ),
        ),
        title: Text(
          deck.name,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (deck.cards.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _playDeck(deck);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Jugar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.woodenBrown,
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _editDeck(deck);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmation(deck);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Eliminar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Baraja'),
        content: Text('¿Estás seguro de que quieres eliminar "${deck.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteDeck(deck.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}