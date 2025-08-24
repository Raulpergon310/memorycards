import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/memory_card.dart';
import '../services/storage_service.dart';

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

  void _showCreateDeckDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Baraja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la baraja',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newDeck = Deck(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  cards: [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                _saveDeck(newDeck);
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _editDeck(Deck deck) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeckEditorScreen(
          deck: deck,
          onSave: _saveDeck,
        ),
      ),
    );
  }

  void _playDeck(Deck deck) {
    Navigator.pushNamed(context, '/game', arguments: deck);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Barajas'),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
      ),
      body: _decks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.style,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes barajas creadas aún',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _showCreateDeckDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear tu primera baraja'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _decks.length,
              itemBuilder: (context, index) {
                final deck = _decks[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deck.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (deck.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      deck.description,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${deck.cards.length} cartas',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: deck.cards.isNotEmpty
                                    ? () => _playDeck(deck)
                                    : null,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Jugar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade400,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _editDeck(deck),
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade400,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _showDeleteConfirmation(deck),
                              icon: const Icon(Icons.delete),
                              color: Colors.red.shade400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDeckDialog,
        backgroundColor: Colors.blue.shade400,
        child: const Icon(Icons.add, color: Colors.white),
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

class DeckEditorScreen extends StatefulWidget {
  final Deck deck;
  final Function(Deck) onSave;

  const DeckEditorScreen({
    Key? key,
    required this.deck,
    required this.onSave,
  }) : super(key: key);

  @override
  State<DeckEditorScreen> createState() => _DeckEditorScreenState();
}

class _DeckEditorScreenState extends State<DeckEditorScreen> {
  late Deck _editedDeck;
  final _frontController = TextEditingController();
  final _backController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editedDeck = widget.deck;
  }

  void _addCard() {
    if (_frontController.text.isNotEmpty && _backController.text.isNotEmpty) {
      final newCard = MemoryCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        front: _frontController.text,
        back: _backController.text,
      );

      setState(() {
        _editedDeck = _editedDeck.copyWith(
          cards: [..._editedDeck.cards, newCard],
          updatedAt: DateTime.now(),
        );
      });

      _frontController.clear();
      _backController.clear();
    }
  }

  void _deleteCard(String cardId) {
    setState(() {
      _editedDeck = _editedDeck.copyWith(
        cards: _editedDeck.cards.where((card) => card.id != cardId).toList(),
        updatedAt: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar: ${widget.deck.name}'),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              widget.onSave(_editedDeck);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agregar Nueva Carta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _frontController,
                  decoration: const InputDecoration(
                    labelText: 'Lado frontal (pregunta)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _backController,
                  decoration: const InputDecoration(
                    labelText: 'Lado trasero (respuesta)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Agregar Carta'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _editedDeck.cards.length,
              itemBuilder: (context, index) {
                final card = _editedDeck.cards[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Frente: ${card.front}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Atrás: ${card.back}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteCard(card.id),
                          icon: const Icon(Icons.delete),
                          color: Colors.red.shade400,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}