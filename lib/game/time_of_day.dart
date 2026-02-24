import 'package:flutter/material.dart';

/// Time of day: four "hours" that advance on travel and after combat.
enum TimeOfDay {
  morn,
  day,
  eve,
  night,
}

extension TimeOfDayExtension on TimeOfDay {
  String get label {
    switch (this) {
      case TimeOfDay.morn:
        return 'Morn';
      case TimeOfDay.day:
        return 'Day';
      case TimeOfDay.eve:
        return 'Eve';
      case TimeOfDay.night:
        return 'Night';
    }
  }

  /// Color representing this time of day for UI.
  Color get color {
    switch (this) {
      case TimeOfDay.morn:
        return const Color(0xFFE8B84C); // soft amber / dawn
      case TimeOfDay.day:
        return const Color(0xFFF5E6A3);  // bright pale yellow
      case TimeOfDay.eve:
        return const Color(0xFFE8952E);  // orange / dusk
      case TimeOfDay.night:
        return const Color(0xFF7B68C4);  // indigo / night
    }
  }

  /// Next time of day. Night -> Morn (caller should also increment day).
  TimeOfDay get next {
    switch (this) {
      case TimeOfDay.morn:
        return TimeOfDay.day;
      case TimeOfDay.day:
        return TimeOfDay.eve;
      case TimeOfDay.eve:
        return TimeOfDay.night;
      case TimeOfDay.night:
        return TimeOfDay.morn;
    }
  }

  bool get isNight => this == TimeOfDay.night;
}
