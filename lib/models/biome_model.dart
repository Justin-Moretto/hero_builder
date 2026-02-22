class BiomeModel {
  final String key; // unique identifier for the biome instance
  final String name;
  final int eventSlotCapacity;
  final List<String> assignedEventNodeKeys;
  /// Biome keys this node connects to on the world map (adjacent travel only).
  final List<String> connectedBiomeKeys;
  /// Map position for layout (0.0..1.0); used by world map widget.
  final double mapX;
  final double mapY;

  const BiomeModel({
    required this.key,
    required this.name,
    required this.eventSlotCapacity,
    this.assignedEventNodeKeys = const [],
    this.connectedBiomeKeys = const [],
    this.mapX = 0.5,
    this.mapY = 0.5,
  }) : assert(eventSlotCapacity >= 0, 'Biome cannot have a negative slot capacity.');

  /// Whether the biome has room to place another event node.
  bool get hasAvailableSlots => assignedEventNodeKeys.length < eventSlotCapacity;

  /// Remaining number of event nodes that can be assigned before the biome is full.
  int get remainingSlots => eventSlotCapacity - assignedEventNodeKeys.length;

  /// Create an updated biome with the provided overrides.
  BiomeModel copyWith({
    String? name,
    int? eventSlotCapacity,
    List<String>? assignedEventNodeKeys,
    List<String>? connectedBiomeKeys,
    double? mapX,
    double? mapY,
  }) {
    return BiomeModel(
      key: key,
      name: name ?? this.name,
      eventSlotCapacity: eventSlotCapacity ?? this.eventSlotCapacity,
      assignedEventNodeKeys: assignedEventNodeKeys ?? this.assignedEventNodeKeys,
      connectedBiomeKeys: connectedBiomeKeys ?? this.connectedBiomeKeys,
      mapX: mapX ?? this.mapX,
      mapY: mapY ?? this.mapY,
    );
  }

  /// Whether the player can travel directly to [biomeKey] from this biome.
  bool isAdjacent(String biomeKey) => connectedBiomeKeys.contains(biomeKey);

  /// Return a biome instance with an additional event node assigned.
  BiomeModel addEventNode(String eventNodeKey) {
    if (assignedEventNodeKeys.contains(eventNodeKey)) {
      return this;
    }
    if (!hasAvailableSlots) {
      throw StateError('Biome $key has no available event slots.');
    }
    return copyWith(
      assignedEventNodeKeys: [
        ...assignedEventNodeKeys,
        eventNodeKey,
      ],
    );
  }

  /// Return a biome instance without the provided event node.
  BiomeModel removeEventNode(String eventNodeKey) {
    if (!assignedEventNodeKeys.contains(eventNodeKey)) {
      return this;
    }
    return copyWith(
      assignedEventNodeKeys: assignedEventNodeKeys
          .where((key) => key != eventNodeKey)
          .toList(growable: false),
    );
  }
}


