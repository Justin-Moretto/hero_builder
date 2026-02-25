import 'package:flutter/material.dart';

/// Main menu: Start Game invokes [onStartGame] to launch a new run.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({
    super.key,
    required this.onStartGame,
  });

  final void Function(BuildContext context) onStartGame;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hero Builder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () => onStartGame(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
