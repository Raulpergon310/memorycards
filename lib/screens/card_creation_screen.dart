import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/memory_card.dart';
import '../theme/app_theme.dart';

class CardCreationScreen extends StatefulWidget {
  final Deck deck;
  final Function(Deck) onSave;

  const CardCreationScreen({
    Key? key,
    required this.deck,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CardCreationScreen> createState() => _CardCreationScreenState();
}

class _CardCreationScreenState extends State<CardCreationScreen> {
  late Deck _editedDeck;
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _deckNameController = TextEditingController();
  bool _isCreatingNewCard = false;
  int? _editingCardIndex;

  @override
  void initState() {
    super.initState();
    _editedDeck = widget.deck;
    _deckNameController.text = _editedDeck.name;
    
    // If deck is new and empty, start creating first card
    if (_editedDeck.cards.isEmpty) {
      _startCreatingNewCard();
    }
  }

  void _startCreatingNewCard() {
    setState(() {
      _isCreatingNewCard = true;
      _editingCardIndex = null;
      _frontController.clear();
      _backController.clear();
    });
  }

  void _editCard(int index) {
    final card = _editedDeck.cards[index];
    setState(() {
      _isCreatingNewCard = true;
      _editingCardIndex = index;
      _frontController.text = card.front;
      _backController.text = card.back;
    });
  }

  void _saveCard() {
    if (_frontController.text.trim().isEmpty || _backController.text.trim().isEmpty) {
      return;
    }

    final newCard = MemoryCard(
      id: _editingCardIndex != null 
          ? _editedDeck.cards[_editingCardIndex!].id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      front: _frontController.text.trim(),
      back: _backController.text.trim(),
    );

    setState(() {
      if (_editingCardIndex != null) {
        // Edit existing card
        final updatedCards = List<MemoryCard>.from(_editedDeck.cards);
        updatedCards[_editingCardIndex!] = newCard;
        _editedDeck = _editedDeck.copyWith(
          cards: updatedCards,
          updatedAt: DateTime.now(),
        );
      } else {
        // Add new card
        _editedDeck = _editedDeck.copyWith(
          cards: [..._editedDeck.cards, newCard],
          updatedAt: DateTime.now(),
        );
      }
      
      _isCreatingNewCard = false;
      _editingCardIndex = null;
      _frontController.clear();
      _backController.clear();
    });
  }

  void _deleteCard(int index) {
    setState(() {
      final updatedCards = List<MemoryCard>.from(_editedDeck.cards);
      updatedCards.removeAt(index);
      _editedDeck = _editedDeck.copyWith(
        cards: updatedCards,
        updatedAt: DateTime.now(),
      );
    });
  }

  void _saveDeck() {
    // Update deck name if it was changed
    final finalDeck = _editedDeck.copyWith(
      name: _deckNameController.text.trim().isEmpty ? 'Nueva Baraja' : _deckNameController.text.trim(),
      updatedAt: DateTime.now(),
    );
    
    widget.onSave(finalDeck);
    Navigator.pop(context);
  }

  void _cancelCardCreation() {
    if (_editedDeck.cards.isEmpty) {
      // If no cards and user cancels, go back
      Navigator.pop(context);
    } else {
      setState(() {
        _isCreatingNewCard = false;
        _editingCardIndex = null;
        _frontController.clear();
        _backController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCreatingNewCard) {
      return _buildCardCreationView();
    } else {
      return _buildDeckOverview();
    }
  }

  Widget _buildCardCreationView() {
    return Scaffold(
      backgroundColor: AppTheme.lightWoodBrown,
      body: SafeArea(
        child: Column(
          children: [
            // Top card (Front)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Container(
                    decoration: AppTheme.getCardDecoration(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            'FRENTE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: TextField(
                              controller: _frontController,
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Escribe la pregunta aquí...',
                                hintStyle: TextStyle(
                                  color: AppTheme.textLight,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Bottom card (Back)
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                  child: Container(
                    decoration: AppTheme.getCardDecoration(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            'ATRÁS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: TextField(
                              controller: _backController,
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppTheme.textDark,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Escribe la respuesta aquí...',
                                hintStyle: TextStyle(
                                  color: AppTheme.textLight,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: AppTheme.getCardDecoration(),
                    child: IconButton(
                      onPressed: _cancelCardCreation,
                      icon: const Icon(Icons.close),
                      color: AppTheme.textDark,
                      iconSize: 32,
                      tooltip: 'Cancelar',
                    ),
                  ),
                  Container(
                    decoration: AppTheme.getCardDecoration(),
                    child: IconButton(
                      onPressed: _saveCard,
                      icon: Icon(_editingCardIndex != null ? Icons.check : Icons.save),
                      color: AppTheme.textDark,
                      iconSize: 32,
                      tooltip: _editingCardIndex != null ? 'Actualizar' : 'Guardar',
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

  Widget _buildDeckOverview() {
    return Scaffold(
      backgroundColor: AppTheme.lightWoodBrown,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: AppTheme.getCardDecoration(),
                      child: TextField(
                        controller: _deckNameController,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Nombre de la baraja',
                          hintStyle: TextStyle(color: AppTheme.textLight),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: AppTheme.getCardDecoration(),
                    child: IconButton(
                      onPressed: _saveDeck,
                      icon: const Icon(Icons.save),
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            // Cards count and add button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_editedDeck.cards.length} cartas',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Container(
                    decoration: AppTheme.getCardDecoration(),
                    child: IconButton(
                      onPressed: _startCreatingNewCard,
                      icon: const Icon(Icons.add),
                      color: AppTheme.textDark,
                      iconSize: 28,
                      tooltip: 'Nueva Carta',
                    ),
                  ),
                ],
              ),
            ),
            
            // Cards list
            Expanded(
              child: _editedDeck.cards.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay cartas aún\nToca "Nueva Carta" para empezar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textLight,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _editedDeck.cards.length,
                      itemBuilder: (context, index) {
                        final card = _editedDeck.cards[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              card.front,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              card.back,
                              style: const TextStyle(
                                color: AppTheme.textLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _editCard(index),
                                  icon: const Icon(Icons.edit),
                                  color: AppTheme.darkWoodBrown,
                                ),
                                IconButton(
                                  onPressed: () => _deleteCard(index),
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
      ),
    );
  }
}