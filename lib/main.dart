import 'package:flutter/material.dart';
import 'screens/deck_manager_screen.dart';
import 'screens/game_screen.dart';
import 'screens/card_creation_screen.dart';
import 'models/deck.dart';
import 'theme/app_theme.dart';
import 'widgets/retro_crt_effect.dart';

void main() {
  runApp(const MemoryCardsApp());
}

class MemoryCardsApp extends StatelessWidget {
  const MemoryCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Cards',
      theme: AppTheme.pixelWoodTheme,
      home: RetroCRTEffect(
        pixelScale: 0.6, // Adjust this value for more/less pixelation
        enableScanlines: false,
        enableVignette: false,
        child: const DeckManagerScreen(),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/game':
            final deck = settings.arguments as Deck;
            return MaterialPageRoute(
              builder: (context) => RetroCRTEffect(
                pixelScale: 0.6,
                enableScanlines: false,
                enableVignette: false,
                child: GameScreen(deck: deck),
              ),
            );
          case '/create-card':
            final args = settings.arguments as Map<String, dynamic>;
            final deck = args['deck'] as Deck;
            final onSave = args['onSave'] as Function(Deck);
            return MaterialPageRoute(
              builder: (context) => RetroCRTEffect(
                pixelScale: 0.6,
                enableScanlines: false,
                enableVignette: false,
                child: CardCreationScreen(
                  deck: deck,
                  onSave: onSave,
                ),
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => RetroCRTEffect(
                pixelScale: 0.6,
                enableScanlines: false,
                enableVignette: false,
                child: const DeckManagerScreen(),
              ),
            );
        }
      },
    );
  }
}
