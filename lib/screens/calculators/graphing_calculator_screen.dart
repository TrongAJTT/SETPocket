import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/widgets/three_panel_layout.dart';
import 'package:setpocket/widgets/graph_calculator/graph_panel.dart';
import 'package:setpocket/widgets/graph_calculator/functions_panel.dart';
import 'package:setpocket/widgets/graph_calculator/history_panel.dart';
import 'package:setpocket/models/graphing_function.dart';
import 'package:setpocket/models/function_group_history.dart';
import 'package:setpocket/services/graphing_calculator_service.dart';
import 'dart:math' as math;
import 'dart:async';

class GraphingCalculatorScreen extends StatefulWidget {
  final bool isEmbedded;

  const GraphingCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  State<GraphingCalculatorScreen> createState() =>
      _GraphingCalculatorScreenState();
}

class _GraphingCalculatorScreenState extends State<GraphingCalculatorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _functionController = TextEditingController();
  final List<GraphingFunction> _functions = [];
  Map<String, List<FlSpot>> _functionDataPoints = {};
  double _minX = -10;
  double _maxX = 10;
  double _minY = -10;
  double _maxY = 10;
  double _centerX = 0;
  double _centerY = 0;
  double _aspectRatio = 1.0;
  bool _isCalculating = false;
  String? _errorMessage;
  final List<String> _functionHistory = [];
  bool _isPanning = false;
  Timer? _panDebounceTimer;
  bool _needsReplot = false;
  Map<String, List<FlSpot>> _cachedFunctionDataPoints = {};
  double _lastPlottedMinX = 0;
  double _lastPlottedMaxX = 0;

  // Joystick control
  bool _isJoystickEnabled = false;

  // Animation and validation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final bool _hasValidationError = false;

  // New state variables for history and settings
  List<FunctionGroupHistory> _groupHistory = [];
  bool _askBeforeLoading = true;
  bool _rememberHistory = true;
  bool _hideHistoryPanel = false;

  // Predefined colors for functions
  final List<Color> _functionColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();

    // Initialize shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    // Load settings, history and state - state loading will override defaults if exists
    _initializeGraphingCalculator();
  }

  Future<void> _initializeGraphingCalculator() async {
    await _loadSettings();
    await _loadHistory();

    // Try to load existing state first
    final stateLoaded = await _loadCurrentState();

    // If no state was loaded, set up defaults
    if (!stateLoaded) {
      _functionController.text = 'x^2';
      _addFunction('x^2');
    }
  }

  @override
  void dispose() {
    _functionController.dispose();
    _panDebounceTimer?.cancel();
    _shakeController.dispose();
    _saveCurrentState(); // Save state when disposing
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final askBeforeLoading =
        await GraphingCalculatorService.getAskBeforeLoading();
    final rememberHistory =
        await GraphingCalculatorService.getRememberHistory();
    setState(() {
      _askBeforeLoading = askBeforeLoading;
      _rememberHistory = rememberHistory;
      _hideHistoryPanel =
          !rememberHistory; // Hide history panel if remember history is disabled
    });
  }

  Future<void> _loadHistory() async {
    if (!_rememberHistory) {
      setState(() {
        _groupHistory = [];
      });
      return; // Don't load history if remember history is disabled
    }

    final history = await GraphingCalculatorService.getHistory();
    setState(() {
      _groupHistory = history;
    });
  }

  Future<bool> _loadCurrentState() async {
    final state = await GraphingCalculatorService.getCurrentState();
    if (state != null) {
      final functions = (state['functions'] as List)
          .map((f) => GraphingFunction(
                id: f['id'],
                expression: f['expression'],
                isVisible: f['isVisible'] ?? true,
                color: Color(f['color']),
                errorMessage: f['errorMessage'],
                createdAt: DateTime.parse(f['createdAt']),
                lastModified: f['lastModified'] != null
                    ? DateTime.parse(f['lastModified'])
                    : null,
              ))
          .toList();

      setState(() {
        _functions.clear();
        _functions.addAll(functions);
        _aspectRatio = state['aspectRatio']?.toDouble() ?? 1.0;
        _applyAspectRatio();
      });

      _plotFunction(forceReplot: true);
      return true; // State was loaded successfully
    }
    return false; // No state to load
  }

  Future<void> _saveCurrentState() async {
    await GraphingCalculatorService.saveCurrentState(_functions, _aspectRatio);
  }

  Future<void> _saveCurrentGroupToHistory() async {
    if (_functions.isEmpty || !_rememberHistory) return;

    await GraphingCalculatorService.saveToHistory(_functions, _aspectRatio);
    await _loadHistory(); // Refresh history list

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.saveCurrentToHistory),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadGroupFromHistory(FunctionGroupHistory group) async {
    // Check if current functions are different from the group to load
    final isDifferent = _functions.isNotEmpty &&
        !GraphingCalculatorService.areFunctionGroupsEqual(
            _functions, group.functions);

    if (_rememberHistory && isDifferent) {
      // Check if we have a saved dialog preference first
      final savedPreference =
          await GraphingCalculatorService.getSaveDialogPreference();

      if (savedPreference != null) {
        // User has a saved preference, use it directly
        if (savedPreference) {
          await _saveCurrentGroupToHistory();
        }
        // Continue with loading regardless of preference
      } else if (_askBeforeLoading) {
        // Only show dialog if ask before loading is enabled and no saved preference
        final result = await _showSaveCurrentGroupDialog();
        if (result == null) return; // User cancelled

        final shouldSave = result['shouldSave'] as bool;
        final rememberChoice = result['rememberChoice'] as bool;

        if (shouldSave) {
          await _saveCurrentGroupToHistory();
        }

        if (rememberChoice) {
          // Save the preference and disable "ask before loading"
          await GraphingCalculatorService.setSaveDialogPreference(shouldSave);
          await GraphingCalculatorService.setAskBeforeLoading(false);
          await _loadSettings(); // Refresh settings
        }
      }
    }

    setState(() {
      _functions.clear();
      _functions.addAll(group.functions.map((f) => GraphingFunction(
            id: f.id,
            expression: f.expression,
            isVisible: f.isVisible,
            color: f.color,
            errorMessage: f.errorMessage,
            createdAt: f.createdAt,
            lastModified: f.lastModified,
          )));
      _aspectRatio = group.aspectRatio;
      _applyAspectRatio();
    });

    _plotFunction(forceReplot: true);
    await _saveCurrentState();
  }

  Future<Map<String, bool>?> _showSaveCurrentGroupDialog() async {
    final l10n = AppLocalizations.of(context)!;
    bool rememberChoice = false;

    return showDialog<Map<String, bool>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.loadHistoryGroup),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.saveCurrentGroupQuestion),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text(l10n.rememberChoice),
                    value: rememberChoice,
                    onChanged: (value) {
                      setDialogState(() {
                        rememberChoice = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop({
                      'shouldSave': false,
                      'rememberChoice': rememberChoice,
                    });
                  },
                  child: Text(l10n.no),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop({
                      'shouldSave': true,
                      'rememberChoice': rememberChoice,
                    });
                  },
                  child: Text(l10n.yes),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _plotFunction({bool forceReplot = false}) async {
    // Skip if already plotting or if bounds haven't changed significantly
    if (_isCalculating && !forceReplot) return;

    // Check if we need to replot based on range changes
    double rangeChangeThreshold = (_maxX - _minX) * 0.1; // 10% of current range
    bool significantRangeChange = forceReplot ||
        (_lastPlottedMinX - _minX).abs() > rangeChangeThreshold ||
        (_lastPlottedMaxX - _maxX).abs() > rangeChangeThreshold ||
        _cachedFunctionDataPoints.isEmpty;

    if (!significantRangeChange && !_needsReplot) {
      // Use cached data points with filtered range
      setState(() {
        _functionDataPoints.clear();
        for (var function in _functions) {
          if (_cachedFunctionDataPoints.containsKey(function.id)) {
            _functionDataPoints[function.id] =
                _cachedFunctionDataPoints[function.id]!
                    .where((point) =>
                        point.x >= _minX &&
                        point.x <= _maxX &&
                        point.y >= _minY &&
                        point.y <= _maxY &&
                        !point.y.isNaN)
                    .toList();
          }
        }
      });
      return;
    }

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      Map<String, List<FlSpot>> newFunctionDataPoints = {};
      Map<String, List<FlSpot>> newCachedDataPoints = {};

      for (var function in _functions) {
        String expression = function.expression.trim();
        if (expression.isEmpty) {
          expression = 'x';
        }

        // Preprocess the expression for math_expressions
        expression = _preprocessExpression(expression);

        List<FlSpot> points = [];
        GrammarParser parser = GrammarParser();
        Expression exp = parser.parse(expression);

        // Calculate broader range for caching
        double plotRange = (_maxX - _minX) * 2; // Plot 2x current range
        double plotMinX = _minX - plotRange * 0.5;
        double plotMaxX = _maxX + plotRange * 0.5;

        double step =
            (plotMaxX - plotMinX) / 800; // More points for smoother curve
        double? lastY;
        const double maxYJump =
            100; // Maximum allowed Y jump between consecutive points

        for (double x = plotMinX; x <= plotMaxX; x += step) {
          try {
            ContextModel cm = ContextModel();
            cm.bindVariable(Variable('x'), Number(x));

            double y = exp.evaluate(EvaluationType.REAL, cm);

            // Check for valid values and discontinuities
            if (!y.isNaN && !y.isInfinite) {
              // Detect large jumps that indicate discontinuities
              if (lastY != null && (y - lastY).abs() > maxYJump) {
                // Add a break point (NaN) to prevent connecting discontinuous segments
                points.add(FlSpot(x - step / 2, double.nan));
              }

              points.add(FlSpot(x, y));
              lastY = y;
            } else {
              // Reset lastY when encountering invalid values
              lastY = null;
            }
          } catch (e) {
            // Reset lastY on calculation errors
            lastY = null;
            continue;
          }
        }

        // Filter out NaN points for final display and split into segments
        List<FlSpot> validPoints = points
            .where((point) =>
                !point.y.isNaN &&
                point.x >= _minX &&
                point.x <= _maxX &&
                point.y >= _minY &&
                point.y <= _maxY)
            .toList();

        newCachedDataPoints[function.id] =
            points; // Cache all points including NaN markers
        newFunctionDataPoints[function.id] = validPoints;

        // Add to history if not already present
        if (!_functionHistory.contains(function.expression)) {
          _functionHistory.insert(0, function.expression);
          if (_functionHistory.length > 10) {
            _functionHistory.removeLast();
          }
        }
      }

      setState(() {
        _cachedFunctionDataPoints = newCachedDataPoints;
        _functionDataPoints = newFunctionDataPoints;
        _isCalculating = false;
        _needsReplot = false;
        _lastPlottedMinX = _minX;
        _lastPlottedMaxX = _maxX;
      });

      // Auto-save state after successful plot
      _saveCurrentState();
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.invalidFunction(e.toString());
        _isCalculating = false;
        _needsReplot = false;
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
      _applyAspectRatio();
      _centerX = 0;
      _centerY = 0;
      _needsReplot = true;
    });
    _plotFunction(forceReplot: true);
  }

  void _resetPlot() {
    setState(() {
      _functionController.text = 'x^2';
      _functions.clear();
      _functionDataPoints.clear();
      _cachedFunctionDataPoints.clear();
      _minX = -10;
      _maxX = 10;
      _applyAspectRatio();
      _centerX = 0;
      _centerY = 0;
      _errorMessage = null;
      _needsReplot = true;
    });
    _addFunction('x^2');
  }

  void _zoomIn() {
    double rangeX = (_maxX - _minX) * 0.25;
    setState(() {
      _minX += rangeX;
      _maxX -= rangeX;
      _applyAspectRatio();
      _centerX = (_minX + _maxX) / 2;
      _centerY = (_minY + _maxY) / 2;
      _needsReplot = true;
    });
    _plotFunction();
    _saveCurrentState(); // Auto-save after zoom
  }

  void _zoomOut() {
    double rangeX = (_maxX - _minX) * 0.5;
    setState(() {
      _minX -= rangeX;
      _maxX += rangeX;
      _applyAspectRatio();
      _centerX = (_minX + _maxX) / 2;
      _centerY = (_minY + _maxY) / 2;
      _needsReplot = true;
    });
    _plotFunction();
    _saveCurrentState(); // Auto-save after zoom
  }

  void _panGraph(double deltaX, double deltaY) {
    double rangeX = (_maxX - _minX);
    double rangeY = (_maxY - _minY);

    // Use sensitivity factor for smoother panning, adjusted for screen size
    double sensitivity = 0.003;

    // Update bounds immediately for visual feedback
    _minX -= deltaX * rangeX * sensitivity; // Invert X for natural panning
    _maxX -= deltaX * rangeX * sensitivity;
    _minY += deltaY * rangeY * sensitivity; // Invert Y for natural scrolling
    _maxY += deltaY * rangeY * sensitivity;
    _centerX = (_minX + _maxX) / 2;
    _centerY = (_minY + _maxY) / 2;

    // Immediate setState for bounds update (lightweight)
    setState(() {
      // Filter existing cached points for immediate visual feedback
      _functionDataPoints.clear();
      for (var function in _functions) {
        if (_cachedFunctionDataPoints.containsKey(function.id)) {
          _functionDataPoints[function.id] =
              _cachedFunctionDataPoints[function.id]!
                  .where((point) =>
                      point.x >= _minX &&
                      point.x <= _maxX &&
                      point.y >= _minY &&
                      point.y <= _maxY &&
                      !point.y.isNaN)
                  .toList();
        }
      }
    });

    // Cancel previous timer
    _panDebounceTimer?.cancel();

    // Set flag for replotting needed
    _needsReplot = true;

    // Debounce the heavy replotting operation
    _panDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (_needsReplot) {
        _plotFunction();
      }
    });
  }

  void _returnToCenter() {
    double rangeX = (_maxX - _minX);
    double rangeY = (_maxY - _minY);

    setState(() {
      _minX = -rangeX / 2;
      _maxX = rangeX / 2;
      _minY = -rangeY / 2;
      _maxY = rangeY / 2;
      _centerX = 0;
      _centerY = 0;
      _needsReplot = true;
    });
    _plotFunction();
  }

  void _toggleJoystick() {
    setState(() {
      _isJoystickEnabled = !_isJoystickEnabled;
    });

    // Show user feedback about gesture mode change
    final l10n = AppLocalizations.of(context)!;
    final message =
        _isJoystickEnabled ? l10n.joystickModeActive : l10n.joystickMode;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onJoystickMove(double deltaX, double deltaY) {
    // Use similar logic to pan but with joystick input
    // deltaX and deltaY come from joystick (typically -1 to 1)
    double sensitivity = 0.15;
    // Invert direction for more intuitive control
    _panGraph(-deltaX * 100 * sensitivity, -deltaY * 100 * sensitivity);
  }

  bool _isOffCenter() {
    return _centerX.abs() > 0.1 || _centerY.abs() > 0.1;
  }

  void _applyAspectRatio() {
    double rangeX = _maxX - _minX;
    double rangeY = rangeX / _aspectRatio;
    double centerY = (_minY + _maxY) / 2;

    _minY = centerY - rangeY / 2;
    _maxY = centerY + rangeY / 2;
  }

  void _setAspectRatio(double ratio) {
    setState(() {
      _aspectRatio = ratio.clamp(0.1, 10.0);
      _applyAspectRatio();
      _needsReplot = true;
    });
    _plotFunction();
    _saveCurrentState(); // Auto-save state when changing aspect ratio
  }

  void _showAspectRatioDialog() {
    final l10n = AppLocalizations.of(context)!;
    double tempRatio = _aspectRatio; // Move outside

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width < 600
                      ? MediaQuery.of(context).size.width * 0.9
                      : 600,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.aspectRatioXY,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.currentRatio(tempRatio.toStringAsFixed(1)),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // Custom slider with specific values
                      _buildAspectRatioSlider(tempRatio, (newRatio) {
                        setDialogState(() {
                          tempRatio = newRatio;
                        });
                      }),

                      const SizedBox(height: 16),

                      // Quick selection buttons
                      _buildQuickRatioButtons(tempRatio, (newRatio) {
                        setDialogState(() {
                          tempRatio = newRatio;
                        });
                      }),

                      const SizedBox(height: 16),
                      Text(
                        tempRatio < 1
                            ? l10n.yAxisWiderThanX(
                                (1 / tempRatio).toStringAsFixed(1))
                            : tempRatio > 1
                                ? l10n.xAxisWiderThanY(
                                    tempRatio.toStringAsFixed(1))
                                : l10n.equalXYRatio,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              setDialogState(() {
                                tempRatio = 1.0;
                              });
                            },
                            child: Text(l10n.reset),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _setAspectRatio(tempRatio);
                              Navigator.of(context).pop();
                            },
                            child: Text(l10n.apply),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAspectRatioSlider(
      double tempRatio, Function(double) onRatioChanged) {
    // Define specific ratio values
    final List<double> ratioValues = [
      0.1,
      0.2,
      0.3,
      0.4,
      0.5,
      0.6,
      0.7,
      0.8,
      0.9,
      1.0,
      2.0,
      3.0,
      4.0,
      5.0,
      6.0,
      7.0,
      8.0,
      9.0,
      10.0
    ];

    // Find index of closest value
    int closestIndex = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < ratioValues.length; i++) {
      double diff = (ratioValues[i] - tempRatio).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }

    return Column(
      children: [
        Slider(
          value: closestIndex.toDouble(),
          min: 0,
          max: (ratioValues.length - 1).toDouble(),
          divisions: ratioValues.length - 1,
          label: '${ratioValues[closestIndex].toStringAsFixed(1)}:1',
          onChanged: (value) {
            int index = value.round();
            onRatioChanged(ratioValues[index]);
          },
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0.1:1'),
            Text('10:1'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickRatioButtons(
      double tempRatio, Function(double) onRatioChanged) {
    final List<double> quickRatios = [0.5, 1.0, 2.0, 5.0];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: quickRatios.map((ratio) {
        final isSelected = (tempRatio - ratio).abs() < 0.1;
        return ChoiceChip(
          label: Text('${ratio.toStringAsFixed(1)}:1'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onRatioChanged(ratio);
            }
          },
        );
      }).toList(),
    );
  }

  Future<void> _removeGroupFromHistory(String id) async {
    await GraphingCalculatorService.removeFromHistory(id);
    await _loadHistory();
  }

  void _showGraphingCalculatorInfo() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: isDesktop ? 600 : screenWidth * 0.9,
          height: isDesktop ? 700 : MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_graph,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.graphingCalculatorDetailedInfo,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.graphingCalculatorOverview,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Features
                      _buildInfoSection(
                        theme,
                        l10n.graphingKeyFeatures,
                        Icons.star_outline,
                        Colors.orange,
                        [
                          _buildFeatureItem(theme, l10n.realTimePlotting,
                              l10n.realTimePlottingDesc, Icons.speed),
                          _buildFeatureItem(theme, l10n.multipleFunction,
                              l10n.multipleFunctionDesc, Icons.functions),
                          _buildFeatureItem(theme, l10n.interactiveControls,
                              l10n.interactiveControlsDesc, Icons.touch_app),
                          _buildFeatureItem(theme, l10n.aspectRatioControl,
                              l10n.aspectRatioControlDesc, Icons.aspect_ratio),
                          _buildFeatureItem(theme, l10n.functionHistory,
                              l10n.functionHistoryDesc, Icons.history),
                          _buildFeatureItem(theme, l10n.mathExpressionSupport,
                              l10n.mathExpressionSupportDesc, Icons.calculate),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // How to Use
                      _buildInfoSection(
                        theme,
                        l10n.graphingHowToUse,
                        Icons.help_outline,
                        Colors.blue,
                        [
                          _buildStepItem(
                              theme, l10n.step1Graph, l10n.step1GraphDesc),
                          _buildStepItem(
                              theme, l10n.step2Graph, l10n.step2GraphDesc),
                          _buildStepItem(
                              theme, l10n.step3Graph, l10n.step3GraphDesc),
                          _buildStepItem(
                              theme, l10n.step4Graph, l10n.step4GraphDesc),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tips
                      _buildInfoSection(
                        theme,
                        l10n.graphingTips,
                        Icons.lightbulb_outline,
                        Colors.green,
                        [
                          _buildTipItem(theme, l10n.tip1Graph),
                          _buildTipItem(theme, l10n.tip2Graph),
                          _buildTipItem(theme, l10n.tip3Graph),
                          _buildTipItem(theme, l10n.tip4Graph),
                          _buildTipItem(theme, l10n.tip5Graph),
                          _buildTipItem(theme, l10n.tip6Graph),
                          _buildTipItem(theme, l10n.tip7Graph),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Supported Functions
                      _buildInfoSection(
                        theme,
                        l10n.supportedFunctions,
                        Icons.category,
                        Colors.purple,
                        [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.basicOperations,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.basicOperationsDesc,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.trigonometricFunctions,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.trigonometricFunctionsDesc,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.logarithmicFunctions,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.logarithmicFunctionsDesc,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.otherFunctions,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.otherFunctionsDesc,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Navigation Controls
                      _buildInfoSection(
                        theme,
                        l10n.navigationControls,
                        Icons.navigation,
                        Colors.indigo,
                        [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.zoomControls,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.zoomControlsDesc,
                                    style: theme.textTheme.bodySmall),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.panControls,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.panControlsDesc,
                                    style: theme.textTheme.bodySmall),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.resetControls,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.resetControlsDesc,
                                    style: theme.textTheme.bodySmall),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.aspectRatioDialog,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.aspectRatioDialogDesc,
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Practical Applications
                      _buildInfoSection(
                        theme,
                        l10n.graphingPracticalApplications,
                        Icons.build,
                        Colors.teal,
                        [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(
                              l10n.graphingPracticalApplicationsDesc,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.close),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String title, IconData icon,
      Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      ThemeData theme, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(ThemeData theme, String step, String description) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.substring(5, 6), // Extract step number
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(ThemeData theme, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Text(
        tip,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final graphContent = Column(
      children: [
        // Graph with floating zoom controls
        Expanded(
          child: GraphPanel(
            functionDataPoints: _functionDataPoints,
            functions: _functions,
            minX: _minX,
            maxX: _maxX,
            minY: _minY,
            maxY: _maxY,
            isCalculating: _isCalculating,
            errorMessage: _errorMessage,
            isPanning: _isPanning,
            onPan: _panGraph,
            onPanStart: (details) {
              // Cancel any pending replot operations
              _panDebounceTimer?.cancel();
              _isPanning = true;
            },
            onPanEnd: (details) {
              _isPanning = false;
              // Cancel debounce timer and immediately replot for final result
              _panDebounceTimer?.cancel();
              _plotFunction(forceReplot: true);
              // Auto-save after pan completes
              Future.delayed(const Duration(milliseconds: 100), () {
                _saveCurrentState();
              });
            },
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
            onReturnToCenter: _returnToCenter,
            isOffCenter: _isOffCenter(),
            isJoystickEnabled: _isJoystickEnabled,
            onJoystickMove: _onJoystickMove,
          ),
        ),
      ],
    );

    // Build main panel actions (previously app bar actions)
    final mainPanelActions = _buildMainPanelActions(context);

    return ThreePanelLayout(
      mainPanel: graphContent,
      topRightPanel: FunctionsPanel(
        functionController: _functionController,
        functions: _functions,
        isCalculating: _isCalculating,
        hasValidationError: _hasValidationError,
        shakeAnimation: _shakeAnimation,
        onAddFunction: _addFunction,
        onRemoveFunction: _removeFunction,
        onToggleVisibility: _toggleFunctionVisibility,
        onUpdateColor: _updateFunctionColor,
        onSaveToHistory: null, // Remove save callback from panel
        showSaveButton: false, // Disable save button in panel
      ),
      bottomRightPanel: _hideHistoryPanel
          ? null
          : HistoryPanel(
              groupHistory: _groupHistory,
              onLoadGroup: _loadGroupFromHistory,
              onRemoveGroup: _removeGroupFromHistory,
              onSaveCurrentGroup: null, // Remove save callback from panel
              showSaveButton: false, // Disable save button in panel
            ),
      mainPanelTitle: l10n.graphPanel,
      topRightPanelTitle: l10n.functionsPanel,
      bottomRightPanelTitle: _hideHistoryPanel ? null : l10n.historyPanel,
      title: l10n.graphingCalculator,
      hideBottomPanel: _hideHistoryPanel,
      mainPanelActions: mainPanelActions,
      topRightPanelActions: _buildFunctionsPanelActions(context),
      bottomRightPanelActions:
          _hideHistoryPanel ? null : _buildHistoryActions(context),
    );
  }

  List<Widget> _buildMainPanelActions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth <= 600;
    final l10n = AppLocalizations.of(context)!;

    if (isMobile) {
      // Mobile: Show info and aspect ratio buttons, plus context menu for other actions
      return [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showGraphingCalculatorInfo,
          tooltip: l10n.info,
        ),
        IconButton(
          icon: const Icon(Icons.aspect_ratio),
          onPressed: _showAspectRatioDialog,
          tooltip: l10n.aspectRatio,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'toggle_joystick':
                _toggleJoystick();
                break;
              case 'reset_plot':
                _resetPlot();
                break;
              case 'reset_zoom':
                _resetZoom();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle_joystick',
              child: ListTile(
                leading: Icon(_isJoystickEnabled
                    ? Icons.gamepad
                    : Icons.gamepad_outlined),
                title: Text(_isJoystickEnabled
                    ? l10n.disableJoystick
                    : l10n.enableJoystick),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'reset_plot',
              child: ListTile(
                leading: const Icon(Icons.clear_all),
                title: Text(l10n.resetPlot),
                dense: true,
              ),
            ),
            PopupMenuItem(
              value: 'reset_zoom',
              child: ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(l10n.resetZoom),
                dense: true,
              ),
            ),
          ],
        ),
      ];
    } else {
      // Desktop: Show all buttons
      return [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showGraphingCalculatorInfo,
          tooltip: l10n.info,
        ),
        IconButton(
          icon: const Icon(Icons.aspect_ratio),
          onPressed: _showAspectRatioDialog,
          tooltip: l10n.aspectRatio,
        ),
        IconButton(
          icon:
              Icon(_isJoystickEnabled ? Icons.gamepad : Icons.gamepad_outlined),
          onPressed: _toggleJoystick,
          tooltip:
              _isJoystickEnabled ? l10n.disableJoystick : l10n.enableJoystick,
        ),
        IconButton(
          icon: const Icon(Icons.clear_all),
          onPressed: _resetPlot,
          tooltip: l10n.resetPlot,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _resetZoom,
          tooltip: l10n.resetZoom,
        ),
      ];
    }
  }

  List<Widget> _buildFunctionsPanelActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <Widget>[];

    // Add save to history button if history is enabled and there are functions
    if (_rememberHistory && _functions.isNotEmpty) {
      actions.add(
        IconButton(
          onPressed: _saveCurrentGroupToHistory,
          icon: const Icon(Icons.bookmark_add, size: 18),
          tooltip: l10n.saveCurrentToHistory,
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      );
    }

    return actions;
  }

  List<Widget> _buildHistoryActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <Widget>[];

    // Add clear history button if there is data to clear
    if (_groupHistory.isNotEmpty) {
      actions.add(
        IconButton(
          onPressed: () => _showClearHistoryDialog(context),
          icon: const Icon(Icons.clear_all, size: 18),
          tooltip: l10n.clearAll,
        ),
      );
    }

    return actions;
  }

  Future<void> _showClearHistoryDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAll),
        content: Text(l10n.confirmClearCalculatorHistory),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await GraphingCalculatorService.clearHistory();
      await _loadHistory();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.calculatorHistoryCleared)),
      );
    }
  }

  void _addFunction(String expression) {
    if (expression.trim().isEmpty) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final color = _functionColors[_functions.length % _functionColors.length];

    final newFunction = GraphingFunction(
      id: id,
      expression: expression.trim(),
      color: color,
    );

    setState(() {
      _functions.add(newFunction);
    });

    _plotFunction(forceReplot: true);
    _saveCurrentState(); // Auto-save state when adding function
  }

  void _removeFunction(String id) {
    setState(() {
      _functions.removeWhere((f) => f.id == id);
      _functionDataPoints.remove(id);
      _cachedFunctionDataPoints.remove(id);
    });
    _saveCurrentState(); // Auto-save state when removing function
  }

  void _toggleFunctionVisibility(String id) {
    setState(() {
      final index = _functions.indexWhere((f) => f.id == id);
      if (index != -1) {
        _functions[index] = _functions[index].copyWith(
          isVisible: !_functions[index].isVisible,
        );
      }
    });
    _saveCurrentState(); // Auto-save state when toggling visibility
  }

  void _updateFunctionColor(String id, Color newColor) {
    setState(() {
      final index = _functions.indexWhere((f) => f.id == id);
      if (index != -1) {
        _functions[index] = _functions[index].copyWith(color: newColor);
      }
    });
    _saveCurrentState();
  }
}
