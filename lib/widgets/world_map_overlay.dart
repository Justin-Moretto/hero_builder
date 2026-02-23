import 'package:flutter/material.dart';

import '../game/world_state.dart';
import '../models/biome_model.dart';

/// Fixed size of the world map canvas (same in portrait and landscape).
const double _mapWidth = 2000;
const double _mapHeight = 1200;

/// Five zoom levels (1x = middle). Index 2 is default.
const List<double> _zoomScales = [0.5, 0.75, 1.0, 1.25, 1.5];
const int _defaultZoomLevel = 2;

/// Inline world map view: pannable canvas of biome nodes.
/// Use in the main content area; bottom bar handles navigation.
/// [onTravel] is called when the user travels to a biome (e.g. to switch back to main view).
class WorldMapView extends StatefulWidget {
  final WorldStateInterface state;
  final List<BiomeModel> biomes;
  final VoidCallback? onTravel;

  const WorldMapView({
    super.key,
    required this.state,
    required this.biomes,
    this.onTravel,
  });

  @override
  State<WorldMapView> createState() => _WorldMapViewState();
}

class _WorldMapViewState extends State<WorldMapView> {
  final TransformationController _transformationController =
      TransformationController();
  bool _initialCenterSet = false;
  int _zoomLevel = _defaultZoomLevel;
  double _viewportW = 0;
  double _viewportH = 0;

  void _applyZoom() {
    if (_viewportW <= 0 || _viewportH <= 0) return;
    final m = _transformationController.value;
    final scale = m.getMaxScaleOnAxis();
    final tx = m.getTranslation().x;
    final ty = m.getTranslation().y;
    final cx = (_viewportW / 2 - tx) / scale;
    final cy = (_viewportH / 2 - ty) / scale;
    final s = _zoomScales[_zoomLevel];
    final newTx = _viewportW / 2 - cx * s;
    final newTy = _viewportH / 2 - cy * s;
    _transformationController.value = Matrix4.identity()
      ..translate(newTx, newTy)
      ..scale(s);
  }

  void _zoomIn() {
    if (_zoomLevel >= _zoomScales.length - 1) return;
    setState(() => _zoomLevel++);
    _applyZoom();
  }

  void _zoomOut() {
    if (_zoomLevel <= 0) return;
    setState(() => _zoomLevel--);
    _applyZoom();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'World Map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: widget.state.currentBiomeKeyNotifier,
                  builder: (context, currentKey, _) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final viewportW = constraints.maxWidth;
                        final viewportH = constraints.maxHeight;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted &&
                              (_viewportW != viewportW || _viewportH != viewportH)) {
                            setState(() {
                              _viewportW = viewportW;
                              _viewportH = viewportH;
                            });
                          }
                        });
                        if (!_initialCenterSet &&
                            viewportW > 0 &&
                            viewportH > 0) {
                          final current = widget.state.getCurrentBiome();
                          if (current != null) {
                            final nodeX = current.mapX * _mapWidth;
                            final nodeY = current.mapY * _mapHeight;
                            final s = _zoomScales[_zoomLevel];
                            final tx = (viewportW / 2 - nodeX * s).clamp(
                              viewportW - _mapWidth * s,
                              0.0,
                            );
                            final ty = (viewportH / 2 - nodeY * s).clamp(
                              viewportH - _mapHeight * s,
                              0.0,
                            );
                            _transformationController.value = Matrix4.identity()
                              ..translate(tx, ty)
                              ..scale(s);
                            _initialCenterSet = true;
                          }
                        }
                        return InteractiveViewer(
                          constrained: false,
                          transformationController: _transformationController,
                          minScale: 0.25,
                          maxScale: 2.0,
                          child: _WorldMapContent(
                            state: widget.state,
                            biomes: widget.biomes,
                            currentBiomeKey: currentKey,
                            mapWidth: _mapWidth,
                            mapHeight: _mapHeight,
                            onTravel: widget.onTravel,
                          ),
                        );
                      },
                    );
                  },
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'map_zoom_in',
                        onPressed: _zoomLevel < _zoomScales.length - 1
                            ? _zoomIn
                            : null,
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'map_zoom_out',
                        onPressed: _zoomLevel > 0 ? _zoomOut : null,
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldMapContent extends StatelessWidget {
  final WorldStateInterface state;
  final List<BiomeModel> biomes;
  final String currentBiomeKey;
  final double mapWidth;
  final double mapHeight;
  final VoidCallback? onTravel;

  const _WorldMapContent({
    required this.state,
    required this.biomes,
    required this.currentBiomeKey,
    required this.mapWidth,
    required this.mapHeight,
    this.onTravel,
  });

  static const double _nodeRadius = 36;

  double _x(BiomeModel b) => b.mapX * mapWidth;
  double _y(BiomeModel b) => b.mapY * mapHeight;

  List<BiomeModel> get _adjacentBiomes {
    final current = state.getCurrentBiome();
    if (current == null) return [];
    return biomes
        .where((b) => b.key != currentBiomeKey && current.isAdjacent(b.key))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final adjacent = _adjacentBiomes;
    return SizedBox(
      width: mapWidth,
      height: mapHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Opaque map background (replace with DecorationImage when you have an asset)
          Positioned.fill(
            child: Container(
              color: Color(0xFF2C2416),
            ),
          ),
          CustomPaint(
            size: Size(mapWidth, mapHeight),
            painter: _WorldMapPainter(
              biomes: biomes,
              currentBiomeKey: currentBiomeKey,
              x: _x,
              y: _y,
            ),
          ),
          for (final biome in biomes) _buildNode(context, biome, adjacent),
        ],
      ),
    );
  }

  void _showTravelConfirm(BuildContext context, BiomeModel biome) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Travel?'),
        content: Text('Travel to ${biome.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              state.travelToBiome(biome.key);
              onTravel?.call();
            },
            child: const Text('Travel'),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(
      BuildContext context, BiomeModel biome, List<BiomeModel> adjacent) {
    final isCurrent = biome.key == currentBiomeKey;
    final canTravel = adjacent.any((b) => b.key == biome.key);
    final cx = _x(biome);
    final cy = _y(biome);

    return Positioned(
      left: cx - _nodeRadius,
      top: cy - _nodeRadius,
      width: _nodeRadius * 2,
      height: _nodeRadius * 2,
      child: Material(
        color: isCurrent
            ? Colors.amber.shade700
            : canTravel
                ? Colors.green.shade800
                : Colors.grey.shade700,
        shape: const CircleBorder(),
        elevation: isCurrent ? 8 : 2,
        child: InkWell(
          onTap: canTravel
              ? () => _showTravelConfirm(context, biome)
              : null,
          customBorder: const CircleBorder(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                biome.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: canTravel || isCurrent ? 15 : 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorldMapPainter extends CustomPainter {
  final List<BiomeModel> biomes;
  final String currentBiomeKey;
  final double Function(BiomeModel) x;
  final double Function(BiomeModel) y;

  _WorldMapPainter({
    required this.biomes,
    required this.currentBiomeKey,
    required this.x,
    required this.y,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final seen = <String>{};
    for (final a in biomes) {
      for (final key in a.connectedBiomeKeys) {
        final edgeKey =
            a.key.compareTo(key) < 0 ? '${a.key}-$key' : '$key-${a.key}';
        if (seen.contains(edgeKey)) continue;
        seen.add(edgeKey);
        BiomeModel? b;
        for (final c in biomes) {
          if (c.key == key) {
            b = c;
            break;
          }
        }
        if (b == null) continue;
        canvas.drawLine(Offset(x(a), y(a)), Offset(x(b), y(b)), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WorldMapPainter oldDelegate) {
    return oldDelegate.currentBiomeKey != currentBiomeKey ||
        oldDelegate.biomes != biomes;
  }
}
