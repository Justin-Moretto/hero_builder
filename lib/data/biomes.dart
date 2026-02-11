import '../models/biome_model.dart';

/// Creates the default set of biomes for the game.
/// Returns new instances so each game can assign event nodes independently.
List<BiomeModel> createDefaultBiomes() => [
  BiomeModel(key: 'village_1', name: 'Village 1', eventSlotCapacity: 4),
  BiomeModel(key: 'village_2', name: 'Village 2', eventSlotCapacity: 4),
  BiomeModel(key: 'forest', name: 'Forest', eventSlotCapacity: 4),
  BiomeModel(key: 'city', name: 'City', eventSlotCapacity: 5),
  BiomeModel(key: 'cave', name: 'Cave', eventSlotCapacity: 4),
  BiomeModel(key: 'castle', name: 'Castle', eventSlotCapacity: 5),
];
