class BiomeModel {
  final String key; // unique identifier for the biome instance
  final String name;
  final int eventSlotCapacity;
  final List<String> assignedEventNodeKeys;

  const BiomeModel({
    required this.key,
    required this.name,
    required this.eventSlotCapacity,
    this.assignedEventNodeKeys = const [],
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
  }) {
    return BiomeModel(
      key: key,
      name: name ?? this.name,
      eventSlotCapacity: eventSlotCapacity ?? this.eventSlotCapacity,
      assignedEventNodeKeys: assignedEventNodeKeys ?? this.assignedEventNodeKeys,
    );
  }

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


