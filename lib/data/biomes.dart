import '../models/biome_model.dart';

/// Creates the default set of biomes for the game with map graph and layout.
/// Returns new instances so each game can assign event nodes independently.
/// Connections are symmetric: travel is allowed only between adjacent nodes.
List<BiomeModel> createDefaultBiomes() => [
      BiomeModel(
        key: 'village_1',
        name: 'Village 1',
        eventSlotCapacity: 4,
        connectedBiomeKeys: ['forest', 'village_2'],
        mapX: 0.32,
        mapY: 0.52,
      ),
      BiomeModel(
        key: 'village_2',
        name: 'Village 2',
        eventSlotCapacity: 4,
        connectedBiomeKeys: ['village_1', 'city'],
        mapX: 0.40,
        mapY: 0.62,
      ),
      BiomeModel(
        key: 'forest',
        name: 'Forest',
        eventSlotCapacity: 4,
        connectedBiomeKeys: ['village_1', 'cave', 'city'],
        mapX: 0.50,
        mapY: 0.48,
      ),
      BiomeModel(
        key: 'city',
        name: 'City',
        eventSlotCapacity: 5,
        connectedBiomeKeys: ['village_2', 'forest', 'castle'],
        mapX: 0.58,
        mapY: 0.54,
      ),
      BiomeModel(
        key: 'cave',
        name: 'Cave',
        eventSlotCapacity: 4,
        connectedBiomeKeys: ['forest'],
        mapX: 0.50,
        mapY: 0.22,
      ),
      BiomeModel(
        key: 'castle',
        name: 'Castle',
        eventSlotCapacity: 5,
        connectedBiomeKeys: ['city'],
        mapX: 0.70,
        mapY: 0.38,
      ),
    ];
