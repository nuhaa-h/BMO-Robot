import 'package:flutter/material.dart';
import 'learn_with_cards_screen.dart';

import 'package:http/http.dart' as http;

// =======================================================
// CONFIG
// =======================================================
const String piIp = "192.168.1.18";

// =======================================================
// API CALL
// =======================================================
Future<void> tellJoke() async {
  try {
    await http.post(
      Uri.parse("http://$piIp:5000/joke"),
    );
  } catch (e) {
    debugPrint("Joke error: $e");
  }
}

// =======================================================
// CHOICE SCREEN
// =======================================================
class ChoiceScreen extends StatelessWidget {
  const ChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              // ===== Title =====
              const Text(
                "What would you like to do?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // ===== Play Game =====
              _ChoiceButton(
                icon: Icons.videogame_asset,
                text: "Play a Game",
                onTap: () {
                  debugPrint("Play Game pressed");
                },
              ),

              const SizedBox(height: 20),

              // ===== Learn Cards =====
              _ChoiceButton(
                icon: Icons.menu_book,
                text: "Learn with Cards",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LearnWithCardsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ===== Joke Button =====
              _ChoiceButton(
                icon: Icons.emoji_emotions,
                text: "Tell me a Joke 😂",
                onTap: () async {
                  await tellJoke();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// REUSABLE BUTTON
// =======================================================
class _ChoiceButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
