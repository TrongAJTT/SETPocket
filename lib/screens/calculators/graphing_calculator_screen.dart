import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../l10n/app_localizations.dart';
import 'dart:math' as math;

class GraphingCalculatorScreen extends StatefulWidget {
  const GraphingCalculatorScreen({super.key});

  @override
  State<GraphingCalculatorScreen> createState() =>
      _GraphingCalculatorScreenState();
}

class _GraphingCalculatorScreenState extends State<GraphingCalculatorScreen> {
  final TextEditingController _functionController = TextEditingController();
  List<FlSpot> _dataPoints = [];
  String _currentFunction = 'x^2';
  double _minX = -10;
  double _maxX = 10;
  double _minY = -10;
  double _maxY = 10;
  bool _isCalculating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _functionController.text = _currentFunction;
    _plotFunction();
  }

  @override
  void dispose() {
    _functionController.dispose();
    super.dispose();
  }

  void _plotFunction() async {
    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      String expression = _functionController.text.trim();
      if (expression.isEmpty) {
        expression = 'x';
      }

      // Preprocess the expression for math_expressions
      expression = _preprocessExpression(expression);

      List<FlSpot> points = [];
      Parser parser = Parser();
      Expression exp = parser.parse(expression);

      double step = (_maxX - _minX) / 200; // 200 points for smooth curve

      for (double x = _minX; x <= _maxX; x += step) {
        try {
          ContextModel cm = ContextModel();
          cm.bindVariable(Variable('x'), Number(x));

          double y = exp.evaluate(EvaluationType.REAL, cm);

          if (!y.isNaN && !y.isInfinite && y >= _minY && y <= _maxY) {
            points.add(FlSpot(x, y));
          }
        } catch (e) {
          // Skip invalid points
          continue;
        }
      }

      setState(() {
        _dataPoints = points;
        _currentFunction = _functionController.text;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid function: ${e.toString()}';
        _isCalculating = false;
      });
    }
  }

  String _preprocessExpression(String expression) {
    // Replace common mathematical notations
    expression = expression.replaceAll('π', math.pi.toString());
    expression = expression.replaceAll('e', math.e.toString());
    expression = expression.replaceAll('sin(', 'sin(');
    expression = expression.replaceAll('cos(', 'cos(');
    expression = expression.replaceAll('tan(', 'tan(');
    expression = expression.replaceAll('ln(', 'log(');
    expression = expression.replaceAll('sqrt(', 'sqrt(');
    expression = expression.replaceAll('abs(', 'abs(');

    return expression;
  }

  void _resetZoom() {
    setState(() {
      _minX = -10;
      _maxX = 10;
      _minY = -10;
      _maxY = 10;
    });
    _plotFunction();
  }

  void _zoomIn() {
    double rangeX = (_maxX - _minX) * 0.25;
    double rangeY = (_maxY - _minY) * 0.25;
    setState(() {
      _minX += rangeX;
      _maxX -= rangeX;
      _minY += rangeY;
      _maxY -= rangeY;
    });
    _plotFunction();
  }

  void _zoomOut() {
    double rangeX = (_maxX - _minX) * 0.5;
    double rangeY = (_maxY - _minY) * 0.5;
    setState(() {
      _minX -= rangeX;
      _maxX += rangeX;
      _minY -= rangeY;
      _maxY += rangeY;
    });
    _plotFunction();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.graphingCalculator),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetZoom,
            tooltip: 'Reset Zoom',
          ),
        ],
      ),
      body: Column(
        children: [
          // Function input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _functionController,
                        decoration: InputDecoration(
                          labelText: 'f(x) = ',
                          hintText: 'Enter function (e.g., x^2, sin(x), etc.)',
                          border: const OutlineInputBorder(),
                          errorText: _errorMessage,
                        ),
                        onSubmitted: (_) => _plotFunction(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isCalculating ? null : _plotFunction,
                      child: _isCalculating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Plot'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Quick function buttons
                Wrap(
                  spacing: 8,
                  children: [
                    _buildQuickFunctionChip('x^2'),
                    _buildQuickFunctionChip('x^3'),
                    _buildQuickFunctionChip('sin(x)'),
                    _buildQuickFunctionChip('cos(x)'),
                    _buildQuickFunctionChip('tan(x)'),
                    _buildQuickFunctionChip('log(x)'),
                    _buildQuickFunctionChip('sqrt(x)'),
                    _buildQuickFunctionChip('abs(x)'),
                  ],
                ),
              ],
            ),
          ),

          // Graph
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _dataPoints.isEmpty && !_isCalculating
                  ? Center(
                      child: Text(
                        _errorMessage ?? 'Enter a function to plot',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minX: _minX,
                        maxX: _maxX,
                        minY: _minY,
                        maxY: _maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _dataPoints,
                            isCurved: true,
                            color: Theme.of(context).primaryColor,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          horizontalInterval: (_maxY - _minY) / 10,
                          verticalInterval: (_maxX - _minX) / 10,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.3),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.3),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: (_maxY - _minY) / 5,
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
                              interval: (_maxX - _minX) / 5,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.labelSmall,
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                        // Add axis lines
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: 0,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  Colors.black,
                              strokeWidth: 1,
                            ),
                          ],
                          verticalLines: [
                            VerticalLine(
                              x: 0,
                              color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color ??
                                  Colors.black,
                              strokeWidth: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Zoom controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _zoomOut,
                  icon: const Icon(Icons.zoom_out),
                  label: const Text('Zoom Out'),
                ),
                ElevatedButton.icon(
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Reset'),
                ),
                ElevatedButton.icon(
                  onPressed: _zoomIn,
                  icon: const Icon(Icons.zoom_in),
                  label: const Text('Zoom In'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFunctionChip(String function) {
    return FilterChip(
      label: Text(function),
      selected: _functionController.text == function,
      onSelected: (selected) {
        if (selected) {
          _functionController.text = function;
          _plotFunction();
        }
      },
    );
  }
}
