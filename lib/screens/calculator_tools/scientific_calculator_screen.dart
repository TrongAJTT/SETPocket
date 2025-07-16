import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/services/calculator_services/calculator_tools_service.dart';
import 'package:setpocket/services/function_info_service.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/layouts/two_panels_layout.dart';
import 'dart:math' as math;
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/settings_models_service.dart';

class ScientificCalculatorScreen extends StatefulWidget {
  final bool isEmbedded;

  const ScientificCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  State<ScientificCalculatorScreen> createState() =>
      _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState
    extends State<ScientificCalculatorScreen> {
  String _display = '0';
  String _expression = '';
  String _realTimeResult = ''; // For real-time calculation display
  bool _isRadians = true;
  bool _showSecondaryFunctions = false;
  List<UnifiedHistoryData> _history = [];
  bool _historyEnabled = false;

  // Calculation stack for recent expressions
  List<String> _calculationStack = [];

  // Flag to track if we just calculated a result
  bool _justCalculated = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _loadState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload history when returning to this screen (e.g., from settings)
    _loadHistory();
  }

  @override
  void dispose() {
    _saveState();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    final history =
        await GenerationHistoryService.getHistory('scientific_calculator');
    setState(() {
      _historyEnabled = settings.rememberHistory;
      _history = history;
    });
  }

  Future<void> _loadState() async {
    final state = await CalculatorToolsService.getScientificCalculatorState();
    if (state != null) {
      setState(() {
        _display = state['display'] ?? '0';
        _expression = state['expression'] ?? '';
        _realTimeResult = state['realTimeResult'] ?? '';
        _isRadians = state['isRadians'] ?? true;
        _showSecondaryFunctions = state['showSecondaryFunctions'] ?? false;
        _calculationStack = List<String>.from(state['calculationStack'] ?? []);
        _justCalculated = state['justCalculated'] ?? false;
      });
    }
  }

  Future<void> _saveState() async {
    try {
      final state = {
        'display': _display,
        'expression': _expression,
        'realTimeResult': _realTimeResult,
        'isRadians': _isRadians,
        'showSecondaryFunctions': _showSecondaryFunctions,
        'calculationStack': _calculationStack,
        'justCalculated': _justCalculated,
      };
      await CalculatorToolsService.saveScientificCalculatorState(state);
    } catch (e) {
      // Silently fail to avoid breaking the app
    }
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
        _realTimeResult = '';
        _justCalculated = false;
        // Clear stack for testing
        _calculationStack.clear();
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _display = _expression.isEmpty ? '0' : _expression;
          _justCalculated = false;
          // Update real-time result
          _updateRealTimeResult();
        }
      } else if (value == '=') {
        _calculate();
        // Save state only when calculation is performed
        _saveState();
      } else if (value == 'Rad/Deg') {
        _isRadians = !_isRadians;
        // Recalculate with new angle mode
        _updateRealTimeResult();
        // Save state for mode change
        _saveState();
      } else if (value == '2nd') {
        _showSecondaryFunctions = !_showSecondaryFunctions;
        // Save state for function toggle
        _saveState();
      } else if (value == '+/-') {
        _toggleSign();
      } else if (_isSpecialFunction(value)) {
        _handleSpecialFunction(value);
      } else {
        // Handle input after calculation
        if (_justCalculated) {
          // If operator, continue with current result
          if (_isOperator(value)) {
            _expression = _display + value;
          } else {
            // If number/constant, start fresh
            _expression = value;
          }
          _justCalculated = false;
        } else if (_display == '0' && !_isOperator(value) && value != '.') {
          _expression = value;
        } else {
          _expression += value;
        }
        _display = _expression;
        // Update real-time result
        _updateRealTimeResult();
      }
    });

    // Only save state for specific actions, not every input
    // This improves performance and only persists meaningful state changes
  }

  void _toggleSign() {
    if (_expression.isNotEmpty && _expression != '0') {
      if (_expression.startsWith('-')) {
        _expression = _expression.substring(1);
      } else {
        _expression = '-$_expression';
      }
      _display = _expression;
    }
  }

  bool _isSpecialFunction(String value) {
    return [
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'log',
      'ln',
      '√',
      '∛',
      'x²',
      'x³',
      'x!',
      'xʸ',
      '1/x',
      '|x|',
      'n!',
      'exp',
      '10ˣ',
      'eˣ',
      'π',
      'e',
      'mod'
    ].contains(value);
  }

  void _handleSpecialFunction(String function) {
    switch (function) {
      case 'sin':
      case 'cos':
      case 'tan':
      case 'asin':
      case 'acos':
      case 'atan':
      case 'log':
      case 'ln':
      case '√':
      case '∛':
        _expression += '$function(';
        break;
      case 'π':
        _expression += 'π';
        break;
      case 'e':
        _expression += 'e';
        break;
      case 'x²':
        _expression += '^2';
        break;
      case 'x³':
        _expression += '^3';
        break;
      case 'x!':
      case 'n!':
        if (_expression.isNotEmpty) {
          _expression = 'factorial($_expression)';
        }
        break;
      case 'xʸ':
        _expression += '^';
        break;
      case '1/x':
        if (_expression.isNotEmpty) {
          _expression = '1/($_expression)';
        } else {
          _expression = '1/';
        }
        break;
      case '|x|':
        if (_expression.isNotEmpty) {
          _expression = 'abs($_expression)';
        } else {
          _expression = 'abs(';
        }
        break;
      case 'exp':
        _expression += 'exp(';
        break;
      case '10ˣ':
        _expression += '10^';
        break;
      case 'eˣ':
        _expression += 'e^';
        break;
      case 'mod':
        _expression += ' % ';
        break;
    }
    _display = _expression;
    // Update real-time result for special functions
    _updateRealTimeResult();
  }

  bool _isOperator(String value) {
    return ['+', '-', '*', '/', '^', '(', ')'].contains(value);
  }

  void _calculate() async {
    try {
      String expression = _expression;
      String originalExpression = _expression; // Store for history

      // Handle special functions and constants
      expression = _preprocessExpression(expression);

      Parser parser = Parser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();

      double result = exp.evaluate(EvaluationType.REAL, cm);

      if (result.isNaN || result.isInfinite) {
        setState(() {
          _display = 'Error';
          _expression = '';
        });
      } else {
        final resultString = _formatResult(result);

        setState(() {
          // Push current calculation to stack before updating display
          if (originalExpression.isNotEmpty &&
              originalExpression != resultString) {
            _pushToCalculationStackInternal(originalExpression, resultString);
          }

          _display = resultString;
          _realTimeResult = ''; // Clear real-time result after calculation
          _expression =
              ''; // Clear expression after calculation to avoid duplication
          _justCalculated = true;
        });

        // Save to history if enabled
        if (_historyEnabled && originalExpression.isNotEmpty) {
          final historyItem = UnifiedHistoryData(
            title: originalExpression,
            value: resultString,
            timestamp: DateTime.now(),
            type: 'scientific_calculator',
          );
          await GenerationHistoryService.addHistoryItem(historyItem);
          await _loadHistory(); // Refresh history
        }

        // Save current state after calculation
        await _saveState();
      }
    } catch (e) {
      setState(() {
        _display = 'Error';
        _expression = '';
      });
    }
  }

  void _pushToCalculationStackInternal(String expression, String result) {
    // Create calculation entry
    String calculationEntry = '$expression = $result';

    // Add to front of stack (most recent first)
    _calculationStack.insert(0, calculationEntry);

    // Keep only last 10 calculations to prevent memory issues
    if (_calculationStack.length > 10) {
      _calculationStack = _calculationStack.take(10).toList();
    }

    // Update previous expression and result for display
  }

  void _updateRealTimeResult() {
    if (_expression.isEmpty || _expression == '0') {
      _realTimeResult = '';
      return;
    }

    try {
      String expression = _expression;

      // Check if expression is complete enough to calculate
      if (_canCalculateExpression(expression)) {
        expression = _preprocessExpression(expression);

        Parser parser = Parser();
        Expression exp = parser.parse(expression);
        ContextModel cm = ContextModel();

        double result = exp.evaluate(EvaluationType.REAL, cm);

        if (!result.isNaN && !result.isInfinite) {
          _realTimeResult = _formatResult(result);
        } else {
          _realTimeResult = '';
        }
      } else {
        _realTimeResult = '';
      }
    } catch (e) {
      _realTimeResult = '';
    }
  }

  bool _canCalculateExpression(String expression) {
    // Don't show real-time result for incomplete expressions
    if (expression.isEmpty) return false;

    // Check for incomplete function calls
    int openParens = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') openParens++;
      if (expression[i] == ')') openParens--;
    }

    // Don't calculate if there are unclosed parentheses
    if (openParens > 0) return false;

    // Don't calculate if expression ends with an operator
    final lastChar = expression[expression.length - 1];
    if (['+', '-', '*', '/', '^', '('].contains(lastChar)) return false;

    // Don't calculate if expression is just a number
    if (double.tryParse(expression) != null) return false;

    return true;
  }

  void _popFromCalculationStack() {
    if (_calculationStack.isNotEmpty) {
      String calculation = _calculationStack.removeAt(0);
      // Parse the calculation to extract expression and result
      List<String> parts = calculation.split(' = ');
      if (parts.length == 2) {
        setState(() {
          _expression = parts[0];
          _display = parts[0];
          _justCalculated = false; // Reset flag
          // Update previous display
          if (_calculationStack.isNotEmpty) {
            String prevCalc = _calculationStack[0];
            List<String> prevParts = prevCalc.split(' = ');
            if (prevParts.length == 2) {}
          } else {}
        });
      }
    }
  }

  String _preprocessExpression(String expression) {
    // Replace constants
    expression = expression.replaceAll('π', math.pi.toString());
    expression = expression.replaceAll('e', math.e.toString());

    // Handle trigonometric functions (convert to radians if needed)
    if (!_isRadians) {
      expression = _convertTrigToRadians(expression);
    }

    // Replace function names with math expressions compatible names
    expression = expression.replaceAll('ln(', 'log(');
    expression = expression.replaceAll('√(', 'sqrt(');
    expression =
        expression.replaceAll('∛(', 'sqrt3('); // Will handle this separately
    expression = expression.replaceAll('abs(', 'abs(');

    // Handle factorial
    expression = _handleFactorial(expression);

    // Handle cube root and other special functions
    expression = _handleSpecialFunctions(expression);

    return expression;
  }

  String _convertTrigToRadians(String expression) {
    // Convert degrees to radians for trig functions
    const degToRad = math.pi / 180;

    // This is a simplified conversion - in a real app you'd want more robust parsing
    expression = expression.replaceAllMapped(
      RegExp(r'sin\(([^)]+)\)'),
      (match) => 'sin(${match.group(1)} * $degToRad)',
    );
    expression = expression.replaceAllMapped(
      RegExp(r'cos\(([^)]+)\)'),
      (match) => 'cos(${match.group(1)} * $degToRad)',
    );
    expression = expression.replaceAllMapped(
      RegExp(r'tan\(([^)]+)\)'),
      (match) => 'tan(${match.group(1)} * $degToRad)',
    );

    return expression;
  }

  String _handleFactorial(String expression) {
    // Handle factorial - this is simplified, a real implementation would be more robust
    return expression.replaceAllMapped(
      RegExp(r'factorial\(([^)]+)\)'),
      (match) {
        try {
          double num = double.parse(match.group(1)!);
          if (num < 0 || num != num.toInt() || num > 170) return 'NaN';
          double result = 1;
          for (int i = 1; i <= num.toInt(); i++) {
            result *= i;
          }
          return result.toString();
        } catch (e) {
          return 'NaN';
        }
      },
    );
  }

  String _handleSpecialFunctions(String expression) {
    // Handle cube root
    expression = expression.replaceAllMapped(
      RegExp(r'sqrt3\(([^)]+)\)'),
      (match) => 'pow(${match.group(1)}, 1/3)',
    );

    // Handle exponential functions
    expression = expression.replaceAll('exp(', 'exp(');

    return expression;
  }

  Widget _buildDisplayContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive font sizes
        double expressionFontSize =
            (constraints.maxHeight * 0.15).clamp(12.0, 16.0);
        double resultFontSize =
            (constraints.maxHeight * 0.25).clamp(18.0, 32.0);
        double labelFontSize = (constraints.maxHeight * 0.12).clamp(10.0, 14.0);

        // Calculate how many stack lines we can show based on available height
        double stackLineHeight =
            math.max(labelFontSize + 6, 20); // Ensure minimum height
        double controlsHeight = labelFontSize +
            16; // RAD/UNDO row height (includes real-time result now)
        double mainDisplayHeight = resultFontSize + 16; // Main result height

        // Real-time result is now in the controls row, so no separate height needed
        double usedHeight =
            controlsHeight + mainDisplayHeight + 24; // 24 for margins
        double availableForStack =
            math.max(0, constraints.maxHeight - usedHeight);

        // Calculate how many lines we can fit (0 to 3) with safety checks
        int maxLines = 0;
        if (stackLineHeight > 0 && availableForStack > 0) {
          double ratio = availableForStack / stackLineHeight;
          if (ratio.isFinite && !ratio.isNaN) {
            maxLines = ratio.floor().clamp(0, 3);
          }
        }

        // Ensure we show at least 1 line if we have calculations and reasonable space
        if (maxLines == 0 &&
            _calculationStack.isNotEmpty &&
            availableForStack >= stackLineHeight * 0.5) {
          maxLines = 1;
        }

        int linesToShow = math.min(maxLines, _calculationStack.length);

        return SingleChildScrollView(
          reverse: true, // Scroll to bottom to show latest content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min, // Important: don't take all space
            children: [
              // Stack display - Show dynamic number of recent calculations
              if (_calculationStack.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0;
                        i <
                            math.min(linesToShow > 0 ? linesToShow : 1,
                                _calculationStack.length);
                        i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: i == 0 ? 4.0 : 2.0),
                        child: Text(
                          _calculationStack[i],
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.color
                                    ?.withValues(alpha: i == 0 ? 0.6 : 0.4),
                                fontSize: labelFontSize * (i == 0 ? 1.0 : 0.8),
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),

              // Current result/display
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _display,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: resultFontSize,
                        color: _justCalculated
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
              ),

              const SizedBox(height: 8),

              // Control row with RAD/DEG and UNDO and result
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _onButtonPressed('Rad/Deg'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _isRadians ? 'RAD' : 'DEG',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: labelFontSize,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Stack control button (pop from stack) - Only show when stack exists
                  if (_calculationStack.isNotEmpty)
                    InkWell(
                      onTap: _popFromCalculationStack,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.undo,
                              size: labelFontSize,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'UNDO',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: labelFontSize,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Real-time result preview (show below main display)
                  if (_realTimeResult.isNotEmpty && !_justCalculated)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '= ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.7),
                                  fontSize: expressionFontSize,
                                ),
                          ),
                          Text(
                            _realTimeResult,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.7),
                                  fontSize: expressionFontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryWidget(AppLocalizations l10n) {
    return _ScientificCalculatorHistoryWidget(
      history: _history,
      onClearHistory: null, // Remove the clear callback - handled by layout
      onRestoreFromHistory: (item, context) {
        setState(() {
          _display = item.value;
          _expression = item.value;
          _justCalculated = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.restored)),
        );
        // Switch to calculator tab on mobile if available
        // This would need TabController access in a more complex implementation
      },
      onRestoreExpression: (expression, context) {
        setState(() {
          _expression = expression;
          _display = expression;
          _justCalculated = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.restored)),
        );
        // Switch to calculator tab on mobile if available
      },
      showHeader:
          false, // Don't show header for desktop - TwoPanelsLayout provides it
    );
  }

  String _formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      return result
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!IsarService.isReady) {
      return const Center(child: CircularProgressIndicator());
    }
    final l10n = AppLocalizations.of(context)!;

    final calculatorContent = LayoutBuilder(
      builder: (context, constraints) {
        // For mobile, use flexible layout; for desktop, use fixed ratios
        final isDesktop = constraints.maxWidth > 600;

        return Column(
          children: [
            // Display section - Fixed height on desktop, flexible on mobile
            Container(
              height: isDesktop
                  ? constraints.maxHeight * 0.25
                  : constraints.maxHeight * 0.2,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: _buildDisplayContent(),
            ),

            // Button section - Takes remaining space
            Expanded(
              child: _buildButtonGrid(),
            ),
          ],
        );
      },
    );

    // Return the calculator layout directly - TwoPanelsLayout handles Scaffold internally
    return TwoPanelsLayout(
      mainPanel: calculatorContent,
      rightPanel: _historyEnabled ? _buildHistoryWidget(l10n) : null,
      title: l10n.scientificCalculator,
      mainPanelTitle: l10n.scientificCalculator,
      rightPanelTitle: _historyEnabled ? l10n.calculationHistory : null,
      isEmbedded: widget.isEmbedded,
      useCompactTabLayout: true,
      showInfoInRightPanelHeader: false,
      mainPanelActions: [
        IconButton(
          onPressed: _showScientificCalculatorInfo,
          icon: const Icon(Icons.info_outline),
          tooltip: l10n.info,
          iconSize: 20,
        ),
      ],
    );
  }

  Widget _buildButtonGrid() {
    List<List<String>> buttonLayout = [
      ['2nd', 'π', 'e', 'C', '⌫'],
      ['x²', '1/x', '|x|', 'exp', 'mod'],
      ['√', '(', ')', 'n!', '/'],
      ['xʸ', '7', '8', '9', '*'],
      ['log', '4', '5', '6', '-'],
      ['ln', '1', '2', '3', '+'],
      ['sin', '+/-', '0', '.', '='],
      ['cos', 'tan', '', '', ''],
    ];

    if (_showSecondaryFunctions) {
      buttonLayout = [
        ['2nd', 'π', 'e', 'C', '⌫'],
        ['x³', '∛', '|x|', 'exp', 'mod'],
        ['x!', '(', ')', '10ˣ', '/'],
        ['xʸ', '7', '8', '9', '*'],
        ['log', '4', '5', '6', '-'],
        ['eˣ', '1', '2', '3', '+'],
        ['asin', '+/-', '0', '.', '='],
        ['acos', 'atan', '', '', ''],
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: buttonLayout.map<Widget>((row) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: row.map<Widget>((buttonText) {
                  if (buttonText.isEmpty) {
                    // Empty button space
                    return const Expanded(child: SizedBox());
                  }
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildButton(buttonText),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String text) {
    Color? buttonColor;
    Color? textColor;
    Widget? buttonContent;

    if (text == 'C' || text == '⌫') {
      // Clear/Delete buttons - Error colors
      buttonColor = Theme.of(context).colorScheme.errorContainer;
      textColor = Theme.of(context).colorScheme.onErrorContainer;
    } else if (text == '=') {
      // Equals button - Primary color
      buttonColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.onPrimary;
    } else if (_isBasicOperator(text)) {
      // Basic operators (+, -, *, /) - Primary color with transparency
      buttonColor =
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
      textColor = Theme.of(context).colorScheme.primary;
    } else if (text == '2nd') {
      // 2nd function toggle - Use icon instead of text
      buttonColor = _showSecondaryFunctions
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surfaceContainerHighest;
      textColor = _showSecondaryFunctions
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSurfaceVariant;
    } else if (_isFunctionButton(text)) {
      // Function buttons (sin, cos, log, etc.) - Secondary color
      buttonColor =
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1);
      textColor = Theme.of(context).colorScheme.secondary;
    } else if (_isNumberButton(text)) {
      // Number buttons - Surface color
      buttonColor = Theme.of(context).colorScheme.surface;
      textColor = Theme.of(context).colorScheme.onSurface;
    } else if (_isConstant(text)) {
      // Constants (π, e) - Tertiary color
      buttonColor =
          Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1);
      textColor = Theme.of(context).colorScheme.tertiary;
    } else {
      // Default for other buttons (parentheses, etc.)
      buttonColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive font size based on button size
        double fontSize = (constraints.maxHeight * 0.25).clamp(12.0, 20.0);

        // Special content for 2nd button (icon instead of text)
        if (text == '2nd') {
          buttonContent = Icon(
            _showSecondaryFunctions ? Icons.functions : Icons.calculate,
            size: fontSize * 1.2,
            color: textColor,
          );
        } else {
          buttonContent = FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          color: buttonColor,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => _onButtonPressed(text),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: buttonContent,
            ),
          ),
        );
      },
    );
  }

  bool _isBasicOperator(String text) {
    return ['+', '-', '*', '/'].contains(text);
  }

  bool _isFunctionButton(String text) {
    return [
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'log',
      'ln',
      'exp',
      'eˣ',
      '10ˣ',
      'x²',
      'x³',
      'xʸ',
      '√',
      '∛',
      '1/x',
      '|x|',
      'n!',
      'x!',
      'mod'
    ].contains(text);
  }

  bool _isNumberButton(String text) {
    return ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '+/-']
        .contains(text);
  }

  bool _isConstant(String text) {
    return ['π', 'e'].contains(text);
  }

  void _showScientificCalculatorInfo() {
    FunctionInfo.show(context, FunctionInfoKeys.scientificCalculator);
  }
}

class _ScientificCalculatorHistoryWidget extends StatefulWidget {
  final List<UnifiedHistoryData> history;
  final VoidCallback? onClearHistory;
  final Function(UnifiedHistoryData, BuildContext) onRestoreFromHistory;
  final Function(String, BuildContext) onRestoreExpression;
  final bool showHeader;

  const _ScientificCalculatorHistoryWidget({
    required this.history,
    this.onClearHistory,
    required this.onRestoreFromHistory,
    required this.onRestoreExpression,
    this.showHeader = true,
  });

  @override
  State<_ScientificCalculatorHistoryWidget> createState() =>
      _ScientificCalculatorHistoryWidgetState();
}

class _ScientificCalculatorHistoryWidgetState
    extends State<_ScientificCalculatorHistoryWidget> {
  Widget _buildCompactHistoryItem(
      AppLocalizations l10n, UnifiedHistoryData item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((item.title ?? '').isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.input,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        widget.onRestoreExpression(item.title ?? '', context),
                    icon: const Icon(Icons.input, size: 18),
                    tooltip: l10n.restoreExpression,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Icon(
                  Icons.output,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => widget.onRestoreFromHistory(item, context),
                  icon: const Icon(Icons.restore, size: 18),
                  tooltip: l10n.restoreResult,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.timestamp.toString().substring(0, 19),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // History header with consistent styling
        if (widget.showHeader)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.calculationHistory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
              ],
            ),
          ),

        // History content
        Expanded(
          child: widget.history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noCalculationHistory,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          l10n.performCalculation,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(4),
                  itemCount: widget.history.length,
                  itemBuilder: (context, index) {
                    final item = widget.history[index];
                    return _buildCompactHistoryItem(l10n, item);
                  },
                ),
        ),
      ],
    );
  }
}
