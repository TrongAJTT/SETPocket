import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/graphing_function.dart';

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

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // The main graph with conditional pan gesture support
          widget.functionDataPoints.isEmpty && !widget.isCalculating
              ? Center(
                  child: Text(
                    widget.errorMessage ?? l10n.enterFunctionToPlot,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : widget.isJoystickEnabled
                  ? // When joystick is enabled, disable pan gesture to avoid conflicts
                  LineChart(
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
                    )
                  : // When joystick is disabled, enable pan gesture
                  GestureDetector(
                      onPanStart: (details) {
                        widget.onPanStart(details);
                        _panStartX = details.localPosition.dx;
                        _panStartY = details.localPosition.dy;
                      },
                      onPanUpdate: (details) {
                        double deltaX = details.localPosition.dx - _panStartX;
                        double deltaY = details.localPosition.dy - _panStartY;

                        // Only pan if movement is significant enough
                        if (deltaX.abs() > 1 || deltaY.abs() > 1) {
                          widget.onPan(deltaX, deltaY);
                          _panStartX = details.localPosition.dx;
                          _panStartY = details.localPosition.dy;
                        }
                      },
                      onPanEnd: widget.onPanEnd,
                      child: LineChart(
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
                      ),
                    ),

          // Floating zoom controls in bottom right
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildFloatingZoomControls(l10n),
          ),

          // Joystick control (only show when enabled)
          if (widget.isJoystickEnabled)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Joystick(
                  mode: JoystickMode.all,
                  listener: (details) {
                    // Add null safety check
                    if (mounted && widget.onJoystickMove != null) {
                      widget.onJoystickMove(details.x, details.y);
                    }
                  },
                  base: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  ),
                  stick: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
      Divider(
        height: 1,
        color: Theme.of(context).dividerColor,
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
        Divider(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
        IconButton(
          onPressed: widget.onReturnToCenter,
          icon: Icon(
            Icons.center_focus_strong,
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark
              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)
              : Theme.of(context).dividerColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: buttons,
      ),
    );
  }

  List<List<FlSpot>> _splitIntoContinuousSegments(List<FlSpot> points) {
    List<List<FlSpot>> segments = [];
    List<FlSpot> currentSegment = [];

    for (int i = 0; i < points.length; i++) {
      FlSpot point = points[i];

      if (point.y.isNaN) {
        // NaN indicates a break - finish current segment and start new one
        if (currentSegment.isNotEmpty) {
          segments.add(List.from(currentSegment));
          currentSegment.clear();
        }
      } else if (point.y >= widget.minY && point.y <= widget.maxY) {
        // Valid point within visible range
        currentSegment.add(point);
      }
    }

    // Add the last segment if it has points
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    return segments;
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      drawHorizontalLine: true,
      horizontalInterval: (widget.maxY - widget.minY) / 10,
      verticalInterval: (widget.maxX - widget.minX) / 10,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          strokeWidth: 1,
        );
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: (widget.maxY - widget.minY) / 5,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelSmall,
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: (widget.maxX - widget.minX) / 5,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelSmall,
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          strokeWidth: 1,
        ),
      ],
      verticalLines: [
        VerticalLine(
          x: 0,
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          strokeWidth: 1,
        ),
      ],
    );
  }

  List<LineChartBarData> _buildLineSegments() {
    List<LineChartBarData> lineBarsData = [];

    for (var function in widget.functions) {
      if (!function.isVisible ||
          !widget.functionDataPoints.containsKey(function.id)) {
        continue;
      }

      List<FlSpot> functionPoints = widget.functionDataPoints[function.id]!;
      if (functionPoints.isEmpty) continue;

      List<List<FlSpot>> segments =
          _splitIntoContinuousSegments(functionPoints);

      for (List<FlSpot> segment in segments) {
        if (segment.isNotEmpty) {
          lineBarsData.add(
            LineChartBarData(
              spots: segment,
              isCurved: true,
              color: function.color,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              isStrokeCapRound: true,
              preventCurveOverShooting: true,
              isStrokeJoinRound: true,
            ),
          );
        }
      }
    }

    return lineBarsData;
  }
}
