import '../models/event_node_model.dart';

/// Creates the default set of event nodes for the game.
/// Each node declares which biomes it can spawn in (biome keys from [createDefaultBiomes]).
List<EventNodeModel> createDefaultEventNodes() => [
  EventNodeModel(
    key: 'blacksmith',
    name: 'Blacksmith',
    description: 'Forge and upgrade gear.',
    biomeOptions: ['village_1', 'village_2', 'city', 'castle'],
  ),
  EventNodeModel(
    key: 'potion_shop',
    name: 'Potion Shop',
    description: 'Buy potions and alchemical supplies.',
    biomeOptions: ['village_1', 'village_2', 'forest', 'city'],
  ),
  EventNodeModel(
    key: 'tavern',
    name: 'Tavern',
    description: 'Rest, gather rumors, and hire help.',
    biomeOptions: ['village_1', 'village_2', 'city'],
  ),
  EventNodeModel(
    key: 'library',
    name: 'Library',
    description: 'Research and learn new abilities.',
    biomeOptions: ['village_1', 'village_2', 'city', 'castle'],
  ),
  EventNodeModel(
    key: 'church',
    name: 'Church',
    description: 'Healing and blessings.',
    biomeOptions: ['village_1', 'village_2', 'city'],
  ),
  EventNodeModel(
    key: 'basic_shop',
    name: 'Basic Shop',
    description: 'General goods and supplies.',
    biomeOptions: ['village_1', 'village_2', 'city'],
  ),
  EventNodeModel(
    key: 'luxury_shop',
    name: 'Luxury Shop',
    description: 'High-end and rare items.',
    biomeOptions: ['city', 'castle'],
  ),
  EventNodeModel(
    key: 'graveyard',
    name: 'Graveyard',
    description: 'Undead encounters and dark rewards.',
    biomeOptions: ['village_1', 'village_2', 'forest', 'city'],
  ),
  EventNodeModel(
    key: 'monument',
    name: 'Monument',
    description: 'Historical site with unique events.',
    biomeOptions: ['village_1', 'village_2', 'city', 'castle'],
  ),
  EventNodeModel(
    key: 'stable',
    name: 'Stable',
    description: 'Mounts and travel supplies.',
    biomeOptions: ['village_1', 'village_2', 'city', 'castle'],
  ),
  EventNodeModel(
    key: 'bank',
    name: 'Bank',
    description: 'Store gold and secure loans.',
    biomeOptions: ['city', 'castle'],
  ),
];
