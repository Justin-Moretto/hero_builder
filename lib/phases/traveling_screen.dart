import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../game/time_of_day.dart' as game_clock;

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

/// Rolls a travel encounter. Hostile (slime) chance is higher at night, lower other times.
TravelEncounterResult rollTravelEncounter(Random random, game_clock.TimeOfDay timeOfDay) {
  final r = random.nextDouble();
  double slimeChance = 0.10;
  double goldChance = 0.25;
  switch (timeOfDay) {
    case game_clock.TimeOfDay.night:
      slimeChance = 0.40;
      goldChance = 0.12;
      break;
    case game_clock.TimeOfDay.morn:
    case game_clock.TimeOfDay.eve:
      slimeChance = 0.15;
      goldChance = 0.22;
      break;
    case game_clock.TimeOfDay.day:
      break;
  }
  if (r < slimeChance) return TravelEncounterResult.slime;
  if (r < slimeChance + goldChance) return TravelEncounterResult.foundGold(20);
  return TravelEncounterResult.none;
}

/// Full-screen "Traveling..." view. Shows animation for [travelDuration],
/// then rolls encounter and calls [onComplete] with the result.
class TravelingScreen extends StatefulWidget {
  final String destinationName;
  final Duration travelDuration;
  final Random random;
  final game_clock.TimeOfDay timeOfDay;
  final void Function(TravelEncounterResult result) onComplete;

  const TravelingScreen({
    super.key,
    required this.destinationName,
    required this.random,
    required this.timeOfDay,
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
      final result = rollTravelEncounter(widget.random, widget.timeOfDay);
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
