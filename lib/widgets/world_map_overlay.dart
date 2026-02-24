import 'package:flutter/material.dart';

import '../game/world_state.dart';
import '../models/biome_model.dart';

/// Fixed size of the world map canvas (square to match square map image).
const double _mapWidth = 1200;
const double _mapHeight = 1200;

/// Five zoom levels (1x = middle). Index 2 is default.
const List<double> _zoomScales = [0.5, 0.75, 1.0, 1.25, 1.5];
const int _defaultZoomLevel = 2;

/// Inline world map view: pannable canvas of biome nodes.
/// Use in the main content area; bottom bar handles navigation.
/// [onTravelToBiome] is called when the user confirms travel to a biome; the host
/// can show a traveling screen and handle encounters before actually moving.
class WorldMapView extends StatefulWidget {
  final WorldStateInterface state;
  final List<BiomeModel> biomes;
  /// Called when user confirms travel to [BiomeModel]. Host shows traveling screen, then moves.
  final void Function(BiomeModel biome)? onTravelToBiome;

  const WorldMapView({
    super.key,
    required this.state,
    required this.biomes,
    this.onTravelToBiome,
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

  /// Scale that fits the full map in the viewport (no black bars when zoomed out).
  double get _fitScale {
    if (_viewportW <= 0 || _viewportH <= 0) return _zoomScales[0];
    final scaleW = _viewportW / _mapWidth;
    final scaleH = _viewportH / _mapHeight;
    return scaleW < scaleH ? scaleW : scaleH;
  }

  double get _effectiveScale {
    final base = _zoomScales[_zoomLevel];
    final fit = _fitScale;
    return base < fit ? fit : base;
  }

  void _applyZoom() {
    if (_viewportW <= 0 || _viewportH <= 0) return;
    final m = _transformationController.value;
    final scale = m.getMaxScaleOnAxis();
    final tx = m.getTranslation().x;
    final ty = m.getTranslation().y;
    final cx = (_viewportW / 2 - tx) / scale;
    final cy = (_viewportH / 2 - ty) / scale;
    final s = _effectiveScale;
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

  void _clampTransformToViewport() {
    if (_viewportW <= 0 || _viewportH <= 0) return;
    final m = _transformationController.value;
    final scaleLo = _fitScale < 2.0 ? _fitScale : 2.0;
    final scaleHi = _fitScale < 2.0 ? 2.0 : _fitScale;
    final scale = m.getMaxScaleOnAxis().clamp(scaleLo, scaleHi);
    final tx = m.getTranslation().x;
    final ty = m.getTranslation().y;
    final txMin = _viewportW - _mapWidth * scale;
    final tyMin = _viewportH - _mapHeight * scale;
    final txLo = txMin <= 0 ? txMin : 0.0;
    final txHi = txMin <= 0 ? 0.0 : txMin;
    final tyLo = tyMin <= 0 ? tyMin : 0.0;
    final tyHi = tyMin <= 0 ? 0.0 : tyMin;
    final txClamped = tx.clamp(txLo, txHi);
    final tyClamped = ty.clamp(tyLo, tyHi);
    if (txClamped != tx || tyClamped != ty || scale != m.getMaxScaleOnAxis()) {
      _transformationController.value = Matrix4.identity()
        ..translate(txClamped, tyClamped)
        ..scale(scale);
    }
  }

  void _scheduleClamp() {
    if (_viewportW <= 0 || _viewportH <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _clampTransformToViewport();
    });
  }

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_scheduleClamp);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_clampTransformToViewport);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF2C2416),
      child: Column(
        children: [
          Expanded(
            child: ClipRect(
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
                            final scaleW = viewportW / _mapWidth;
                            final scaleH = viewportH / _mapHeight;
                            final fitScale = scaleW < scaleH ? scaleW : scaleH;
                            final s = _zoomScales[_zoomLevel] < fitScale ? fitScale : _zoomScales[_zoomLevel];
                            final txMin = viewportW - _mapWidth * s;
                            final tyMin = viewportH - _mapHeight * s;
                            final txLo = txMin <= 0 ? txMin : 0.0;
                            final txHi = txMin <= 0 ? 0.0 : txMin;
                            final tyLo = tyMin <= 0 ? tyMin : 0.0;
                            final tyHi = tyMin <= 0 ? 0.0 : tyMin;
                            final tx = (viewportW / 2 - nodeX * s).clamp(txLo, txHi);
                            final ty = (viewportH / 2 - nodeY * s).clamp(tyLo, tyHi);
                            _transformationController.value = Matrix4.identity()
                              ..translate(tx, ty)
                              ..scale(s);
                            _initialCenterSet = true;
                          }
                        }
                        final fitScale = viewportW > 0 && viewportH > 0
                            ? (viewportW / _mapWidth) < (viewportH / _mapHeight)
                                ? viewportW / _mapWidth
                                : viewportH / _mapHeight
                            : 0.25;
                        return InteractiveViewer(
                          constrained: false,
                          transformationController: _transformationController,
                          minScale: fitScale,
                          maxScale: 2.0,
                          child: _WorldMapContent(
                            state: widget.state,
                            biomes: widget.biomes,
                            currentBiomeKey: currentKey,
                            mapWidth: _mapWidth,
                            mapHeight: _mapHeight,
                            onTravelToBiome: widget.onTravelToBiome,
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black87,
                        onPressed: _zoomLevel < _zoomScales.length - 1
                            ? _zoomIn
                            : null,
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'map_zoom_out',
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.black87,
                        onPressed: _zoomLevel > 0 ? _zoomOut : null,
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
  final void Function(BiomeModel biome)? onTravelToBiome;

  const _WorldMapContent({
    required this.state,
    required this.biomes,
    required this.currentBiomeKey,
    required this.mapWidth,
    required this.mapHeight,
    this.onTravelToBiome,
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
          Positioned.fill(
            child: Image.asset(
              'assets/images/placeholder_map.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Color(0xFF2C2416),
              ),
            ),
          ),
          CustomPaint(
            size: Size(mapWidth, mapHeight),
            painter: _WorldMapPainter(
              biomes: biomes,
              currentBiomeKey: currentBiomeKey,
              x: _x,
              y: _y,
              lineColor: Theme.of(context).colorScheme.primary,
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
              onTravelToBiome?.call(biome);
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
            ? Theme.of(context).colorScheme.secondary
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
  final Color lineColor;

  _WorldMapPainter({
    required this.biomes,
    required this.currentBiomeKey,
    required this.x,
    required this.y,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
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
        oldDelegate.biomes != biomes ||
        oldDelegate.lineColor != lineColor;
  }
}
