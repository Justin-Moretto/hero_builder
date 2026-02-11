import 'dart:math';

class EventNodeModel {
  final String key; // unique identifier for the event node
  final String name;
  final String? description;
  final List<String> biomeOptions;

  const EventNodeModel({
    required this.key,
    required this.name,
    this.description,
    required this.biomeOptions,
  }) : assert(
          biomeOptions.length > 0,
          'Event node must provide at least one biome option.',
        );

  /// Whether the node must be placed exclusively in a single biome each run.
  /// When more than one biome is provided, one should be selected per playthrough.
  bool get isBiomeExclusive => biomeOptions.length > 1;

  /// Check if the event node is allowed to spawn in the provided biome.
  bool canSpawnInBiome(String biomeKey) => biomeOptions.contains(biomeKey);

  /// Select a biome for this event node using the provided random source.
  ///
  /// When multiple biome options exist, one is chosen at random to satisfy the
  /// exclusivity requirement. When only a single biome option exists, it is returned.
  String selectBiomeForRun(Random random) {
    if (biomeOptions.length == 1) {
      return biomeOptions.first;
    }

    return biomeOptions[random.nextInt(biomeOptions.length)];
  }

  /// Create an updated event node with the provided overrides.
  EventNodeModel copyWith({
    String? name,
    String? description,
    List<String>? biomeOptions,
  }) {
    return EventNodeModel(
      key: key,
      name: name ?? this.name,
      description: description ?? this.description,
      biomeOptions: biomeOptions ?? this.biomeOptions,
    );
  }
}


