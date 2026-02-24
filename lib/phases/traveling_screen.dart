import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// Result of a travel encounter roll. Shown in a popup before proceeding.
enum TravelEncounter {
  /// No encounter; proceed to destination.
  none,
  /// Random slime encounter; user must fight before arriving.
  slime,
  /// Found gold on the road; add [goldAmount] then proceed.
  foundGold,
}

/// Immutable result of rolling a travel encounter.
class TravelEncounterResult {
  final TravelEncounter type;
  final int goldAmount;

  const TravelEncounterResult._(this.type, [this.goldAmount = 0]);

  static const TravelEncounterResult none = TravelEncounterResult._(TravelEncounter.none);
  static const TravelEncounterResult slime = TravelEncounterResult._(TravelEncounter.slime);

  static TravelEncounterResult foundGold(int amount) =>
      TravelEncounterResult._(TravelEncounter.foundGold, amount);
}

/// Rolls a travel encounter: 20% slime, 20% find 20 gold, 60% none.
TravelEncounterResult rollTravelEncounter(Random random) {
  final r = random.nextDouble();
  if (r < 0.20) return TravelEncounterResult.slime;
  if (r < 0.40) return TravelEncounterResult.foundGold(20);
  return TravelEncounterResult.none;
}

/// Full-screen "Traveling..." view. Shows animation for [travelDuration],
/// then rolls encounter and calls [onComplete] with the result.
class TravelingScreen extends StatefulWidget {
  final String destinationName;
  final Duration travelDuration;
  final Random random;
  final void Function(TravelEncounterResult result) onComplete;

  const TravelingScreen({
    super.key,
    required this.destinationName,
    required this.random,
    required this.onComplete,
    this.travelDuration = const Duration(milliseconds: 1800),
  });

  @override
  State<TravelingScreen> createState() => _TravelingScreenState();
}

class _TravelingScreenState extends State<TravelingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    Future.delayed(widget.travelDuration, () {
      if (!mounted) return;
      final result = rollTravelEncounter(widget.random);
      widget.onComplete(result);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[900],
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final opacity = 0.5 + 0.5 * _pulseController.value;
                  return Opacity(
                    opacity: opacity,
                    child: Icon(
                      Icons.directions_walk,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Traveling...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'to ${widget.destinationName}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
