import 'package:flutter/material.dart';
import 'screens/deck_manager_screen.dart';
import 'screens/game_screen.dart';
import 'models/deck.dart';

void main() {
  runApp(const MemoryCardsApp());
}

class MemoryCardsApp extends StatelessWidget {
  const MemoryCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Cards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DeckManagerScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/game':
            final deck = settings.arguments as Deck;
            return MaterialPageRoute(
              builder: (context) => GameScreen(deck: deck),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const DeckManagerScreen(),
            );
        }
      },
    );
  }
}
