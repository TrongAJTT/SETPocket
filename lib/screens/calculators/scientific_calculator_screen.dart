import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/calculator_history_service.dart';
import 'package:setpocket/widgets/calculator_layout.dart';
import 'dart:math' as math;

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
  List<CalculatorHistoryItem> _history = [];
  bool _historyEnabled = false;

  // Calculation stack for recent expressions
  List<String> _calculationStack = [];

  // Flag to track if we just calculated a result
  bool _justCalculated = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload history when returning to this screen (e.g., from settings)
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final enabled = await CalculatorHistoryService.isHistoryEnabled();
    final history = await CalculatorHistoryService.getHistory('scientific');
    setState(() {
      _historyEnabled = enabled;
      _history = history;
    });
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
      } else if (value == 'Rad/Deg') {
        _isRadians = !_isRadians;
        // Recalculate with new angle mode
        _updateRealTimeResult();
      } else if (value == '2nd') {
        _showSecondaryFunctions = !_showSecondaryFunctions;
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

      ShuntingYardParser parser = ShuntingYardParser();
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
          await CalculatorHistoryService.addHistoryItem(
            originalExpression,
            resultString,
            'scientific',
          );
          await _loadHistory(); // Refresh history
        }
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

  // void _pushToCalculationStack(String expression, String result) {
  //   setState(() {
  //     _pushToCalculationStackInternal(expression, result);
  //   });
  // }

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

        ShuntingYardParser parser = ShuntingYardParser();
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

  void _restoreFromHistory(CalculatorHistoryItem item) {
    setState(() {
      _expression = item.expression;
      _display = item.result;
      _justCalculated = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.restored)),
    );
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

              // // Current expression (show when typing or after calculation)
              // if (_expression.isNotEmpty && _expression != _display)
              //   Padding(
              //     padding: const EdgeInsets.only(bottom: 4),
              //     child: Text(
              //       _expression,
              //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              //             color: Theme.of(context)
              //                 .textTheme
              //                 .bodyMedium
              //                 ?.color
              //                 ?.withValues(alpha: 0.8),
              //             fontSize: expressionFontSize,
              //           ),
              //       overflow: TextOverflow.ellipsis,
              //     ),
              //   ),

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

  Widget _buildHistoryWidget(AppLocalizations loc) {
    return CalculatorHistoryWidget(
      historyType: 'scientific',
      history: _history,
      title: loc.calculationHistory,
      onClearHistory: () async {
        await CalculatorHistoryService.clearHistory('scientific');
        await _loadHistory();
      },
      customItemBuilder: (item, context) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expression
                if (item.expression.isNotEmpty) ...[
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
                          item.expression,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.restore, size: 16),
                        onPressed: () => _restoreFromHistory(item),
                        tooltip: 'Restore',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Result
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
                        item.result,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),
                  ],
                ),

                // Timestamp
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.timestamp.toString().substring(0, 19),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
    final l10n = AppLocalizations.of(context)!;

    final calculatorContent = LayoutBuilder(
      builder: (context, constraints) {
        // For mobile, use flexible layout; for desktop, use fixed ratios
        final isDesktop = constraints.maxWidth > 600;

        return Column(
          children: [
            // Display section - Fixed height on desktop, flexible on mobile
            Container(
              // height: isDesktop ? constraints.maxHeight * 0.25 : null,
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

    return CalculatorLayout(
      calculatorContent: calculatorContent,
      historyWidget: _historyEnabled ? _buildHistoryWidget(l10n) : null,
      historyEnabled: _historyEnabled,
      hasHistory: _history.isNotEmpty,
      isEmbedded: widget.isEmbedded,
      title: l10n.scientificCalculator,
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
      padding: const EdgeInsets.all(8),
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
}
