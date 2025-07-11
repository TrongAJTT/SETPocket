import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/calculator_models/graphing_function.dart';
import 'package:setpocket/widgets/generic/virtual_joystick_detector.dart';

class GraphPanel extends StatefulWidget {
  final Map<String, List<FlSpot>> functionDataPoints;
  final List<GraphingFunction> functions;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final bool isCalculating;
  final String? errorMessage;
  final bool isPanning;
  final Function(double deltaX, double deltaY) onPan;
  final Function(DragStartDetails) onPanStart;
  final Function(DragEndDetails) onPanEnd;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReturnToCenter;
  final bool isOffCenter;
  final bool isJoystickEnabled;
  final Function(double deltaX, double deltaY) onJoystickMove;

  const GraphPanel({
    super.key,
    required this.functionDataPoints,
    required this.functions,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.isCalculating,
    this.errorMessage,
    required this.isPanning,
    required this.onPan,
    required this.onPanStart,
    required this.onPanEnd,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReturnToCenter,
    required this.isOffCenter,
    this.isJoystickEnabled = false,
    required this.onJoystickMove,
  });

  @override
  State<GraphPanel> createState() => _GraphPanelState();
}

class _GraphPanelState extends State<GraphPanel> {
  double _panStartX = 0;
  double _panStartY = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const joystickRadius = 50.0;

    return LayoutBuilder(builder: (context, constraints) {
      final joystickBasePosition = Offset(
        joystickRadius + 24, // Padding from left
        constraints.maxHeight - joystickRadius - 24, // Padding from bottom
      );

      final graphContent =
          widget.functionDataPoints.isEmpty && !widget.isCalculating
              ? Center(
                  child: Text(
                    widget.errorMessage ?? l10n.enterFunctionToPlot,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : LineChart(
                  LineChartData(
                    minX: widget.minX,
                    maxX: widget.maxX,
                    minY: widget.minY,
                    maxY: widget.maxY,
                    lineTouchData: const LineTouchData(enabled: false),
                    lineBarsData: _buildLineSegments(),
                    gridData: _buildGridData(),
                    titlesData: _buildTitlesData(),
                    borderData: _buildBorderData(),
                    extraLinesData: _buildExtraLinesData(),
                  ),
                );

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Main graph area with its own gesture detector for panning
              GestureDetector(
                onPanStart: widget.isJoystickEnabled
                    ? null
                    : (details) {
                        widget.onPanStart(details);
                        _panStartX = details.localPosition.dx;
                        _panStartY = details.localPosition.dy;
                      },
                onPanUpdate: widget.isJoystickEnabled
                    ? null
                    : (details) {
                        final deltaX = details.localPosition.dx - _panStartX;
                        final deltaY = details.localPosition.dy - _panStartY;
                        if (deltaX.abs() > 1 || deltaY.abs() > 1) {
                          widget.onPan(deltaX, deltaY);
                          _panStartX = details.localPosition.dx;
                          _panStartY = details.localPosition.dy;
                        }
                      },
                onPanEnd: widget.isJoystickEnabled ? null : widget.onPanEnd,
                child: graphContent,
              ),

              // Floating zoom controls in bottom right
              Positioned(
                bottom: 16,
                right: 16,
                child: _buildFloatingZoomControls(l10n),
              ),

              // Joystick as a separate, positioned overlay
              if (widget.isJoystickEnabled)
                Positioned(
                  left: joystickBasePosition.dx - joystickRadius,
                  top: joystickBasePosition.dy - joystickRadius,
                  width: joystickRadius * 2,
                  height: joystickRadius * 2,
                  child: VirtualJoystickDetector(
                    // These callbacks are not needed as joystick handles its own gestures
                    onDragStart: (_) {},
                    onDragUpdate: (_) {},
                    onDragEnd: (_) {},
                    onTap: (_) {},
                    // Joystick configuration
                    showVisualJoystick: true,
                    joystickMode: JoystickMode.fixed,
                    fixedPosition: const Offset(joystickRadius,
                        joystickRadius), // Center within its own bounds
                    joystickRadius: joystickRadius,
                    continuousUpdate: true,
                    sensitivity: 5.0,
                    invertX: true,
                    invertY: true,
                    onMove: (delta) {
                      widget.onJoystickMove(delta.dx, delta.dy);
                    },
                    child: Container(), // The detector is its own visual
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFloatingZoomControls(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<Widget> buttons = [
      IconButton(
        onPressed: widget.onZoomIn,
        icon: Icon(
          Icons.zoom_in,
          color: isDark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
        tooltip: l10n.zoomIn,
        iconSize: 20,
      ),
      const Divider(
        height: 1,
        color: null,
      ),
      IconButton(
        onPressed: widget.onZoomOut,
        icon: Icon(
          Icons.zoom_out,
          color: isDark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
        tooltip: l10n.zoomOut,
        iconSize: 20,
      ),
    ];

    // Add return to center button if off center
    if (widget.isOffCenter) {
      buttons.addAll([
        const Divider(
          height: 1,
          color: null,
        ),
        IconButton(
          onPressed: widget.onReturnToCenter,
          icon: Icon(
            Icons.filter_center_focus,
            color: isDark
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: l10n.returnToCenter,
          iconSize: 20,
        ),
      ]);
    }

    return Container(
      width: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: buttons,
      ),
    );
  }

  List<LineChartBarData> _buildLineSegments() {
    List<LineChartBarData> lineBars = [];
    for (var function in widget.functions) {
      if (!function.isVisible) continue;

      var points = widget.functionDataPoints[function.id] ?? [];
      if (points.isEmpty) continue;

      List<List<FlSpot>> segments = [];
      List<FlSpot> currentSegment = [];

      for (var point in points) {
        if (point.y.isNaN) {
          if (currentSegment.isNotEmpty) {
            segments.add(List.from(currentSegment));
            currentSegment.clear();
          }
        } else {
          currentSegment.add(point);
        }
      }
      if (currentSegment.isNotEmpty) {
        segments.add(currentSegment);
      }

      for (var segment in segments) {
        if (segment.length > 1) {
          lineBars.add(
            LineChartBarData(
              spots: segment,
              isCurved: false,
              color: function.color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          );
        }
      }
    }
    return lineBars;
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      drawHorizontalLine: true,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: value == 0
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
              : Theme.of(context).dividerColor,
          strokeWidth: value == 0 ? 1.5 : 0.5,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: value == 0
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
              : Theme.of(context).dividerColor,
          strokeWidth: value == 0 ? 1.5 : 0.5,
        );
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            if (value == widget.maxY || value == widget.minY) {
              return const SizedBox.shrink(); // Hide top and bottom titles
            }
            return Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          getTitlesWidget: (value, meta) {
            if (value == widget.maxX || value == widget.minX) {
              return const SizedBox.shrink(); // Hide left and right titles
            }
            return Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border.all(
        color: Theme.of(context).dividerColor,
        width: 1,
      ),
    );
  }

  ExtraLinesData _buildExtraLinesData() {
    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: 0,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          strokeWidth: 1.5,
        ),
      ],
      verticalLines: [
        VerticalLine(
          x: 0,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          strokeWidth: 1.5,
        ),
      ],
    );
  }
}
