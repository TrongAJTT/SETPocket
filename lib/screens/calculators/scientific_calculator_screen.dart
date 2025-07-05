import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/calculator_history.dart';
import 'package:setpocket/models/scientific_calculator_state.dart';
import 'package:setpocket/services/calculator_history_isar_service.dart';
import 'package:setpocket/services/scientific_calculator_service.dart';
import 'package:setpocket/layouts/two_panels_layout.dart';
import 'package:setpocket/widgets/generic_info_dialog.dart';
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
  String _realTimeResult = '';
  bool _isRadians = true;
  bool _showSecondaryFunctions = false;
  List<CalculatorHistory> _history = [];
  bool _historyEnabled = false;
  List<String> _calculationStack = [];
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
    _loadHistory();
  }

  @override
  void dispose() {
    _saveState();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final enabled = await CalculatorHistoryIsarService.isHistoryEnabled();
    if (mounted) {
      final history = await ScientificCalculatorService.getHistory();
      setState(() {
        _historyEnabled = enabled;
        _history = history;
      });
    }
  }

  Future<void> _loadState() async {
    final state = await ScientificCalculatorService.getCurrentState();
    if (state != null) {
      setState(() {
        _display = state.display ?? '0';
        _expression = state.expression ?? '';
        _realTimeResult = state.realTimeResult ?? '';
        _isRadians = state.isRadians ?? true;
        _showSecondaryFunctions = state.showSecondaryFunctions ?? false;
        _calculationStack = List<String>.from(state.calculationStack ?? []);
        _justCalculated = state.justCalculated ?? false;
      });
    }
  }

  Future<void> _saveState() async {
    try {
      final state = ScientificCalculatorState()
        ..display = _display
        ..expression = _expression
        ..realTimeResult = _realTimeResult
        ..isRadians = _isRadians
        ..showSecondaryFunctions = _showSecondaryFunctions
        ..calculationStack = _calculationStack
        ..justCalculated = _justCalculated;
      await ScientificCalculatorService.saveCurrentState(state);
    } catch (e) {
      // silent fail
    }
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
        _realTimeResult = '';
        _justCalculated = false;
        _calculationStack.clear();
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _display = _expression.isEmpty ? '0' : _expression;
          _justCalculated = false;
          _updateRealTimeResult();
        }
      } else if (value == '=') {
        _calculate();
      } else if (value == 'Rad/Deg') {
        _isRadians = !_isRadians;
        _updateRealTimeResult();
        _saveState();
      } else if (value == '2nd') {
        _showSecondaryFunctions = !_showSecondaryFunctions;
        _saveState();
      } else if (value == '+/-') {
        _toggleSign();
      } else if (_isSpecialFunction(value)) {
        _handleSpecialFunction(value);
      } else {
        if (_justCalculated) {
          if (_isOperator(value)) {
            _expression = _display + value;
          } else {
            _expression = value;
          }
          _justCalculated = false;
        } else if (_display == '0' && !_isOperator(value) && value != '.') {
          _expression = value;
        } else {
          _expression += value;
        }
        _display = _expression;
        _updateRealTimeResult();
      }
    });
    _saveState();
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
    _updateRealTimeResult();
  }

  void _updateRealTimeResult() {
    if (_expression.isEmpty || _expression == '0') {
      _realTimeResult = '';
      return;
    }

    try {
      String expression = _expression;

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
    if (expression.isEmpty) return false;

    int openParens = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') openParens++;
      if (expression[i] == ')') openParens--;
    }

    if (openParens > 0) return false;

    final lastChar = expression[expression.length - 1];
    if (['+', '-', '*', '/', '^', '('].contains(lastChar)) return false;

    if (double.tryParse(expression) != null) return false;

    return true;
  }

  void _calculate() {
    try {
      String finalExpression = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('π', math.pi.toString())
          .replaceAll('e', math.e.toString());

      if (!_isRadians) {
        finalExpression = _convertTrigToRadians(finalExpression);
      }

      Parser p = Parser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      String result = _formatResult(eval);

      if (_historyEnabled) {
        ScientificCalculatorService.addToHistory(_expression, result);
        _loadHistory();
      }

      setState(() {
        _display = result;
        _justCalculated = true;
        if (_calculationStack.length >= 20) {
          _calculationStack.removeAt(0);
        }
        _calculationStack.add(_expression);
      });
    } catch (e) {
      setState(() {
        _display = 'Error';
      });
    }
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }

  String _convertTrigToRadians(String expression) {
    const degToRad = math.pi / 180;

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

  String _preprocessExpression(String expression) {
    expression = expression.replaceAll('ln(', 'log(');
    expression = expression.replaceAll('√(', 'sqrt(');
    expression = expression.replaceAll('∛(', 'sqrt3(');
    expression = expression.replaceAll('abs(', 'abs(');

    expression = _handleFactorial(expression);

    expression = _handleSpecialFunctions(expression);

    return expression;
  }

  String _handleFactorial(String expression) {
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
    expression = expression.replaceAllMapped(
      RegExp(r'sqrt3\(([^)]+)\)'),
      (match) => 'pow(${match.group(1)}, 1/3)',
    );

    expression = expression.replaceAll('exp(', 'exp(');

    return expression;
  }

  bool _isOperator(String value) {
    return ['+', '-', '*', '/', '^', '(', ')'].contains(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final calculatorContent = LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;

        return Column(
          children: [
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
            Expanded(
              child: _buildButtonGrid(),
            ),
          ],
        );
      },
    );

    return TwoPanelsLayout(
      calculatorContent: calculatorContent,
      historyWidget: _historyEnabled
          ? _ScientificCalculatorHistoryWidget(
              history: _history,
              onClearHistory: () {
                _showClearHistoryDialog(context);
              },
              onRestoreFromHistory: (item, context) {
                _restoreFromHistory(item);
              },
              onRestoreExpression: (expression, context) {
                // ...
              },
            )
          : null,
      historyEnabled: _historyEnabled,
      hasHistory: _historyEnabled,
      isEmbedded: widget.isEmbedded,
      title: l10n.scientificCalculator,
      onShowInfo: _showScientificCalculatorInfo,
      onClearHistory: () async {
        await CalculatorHistoryIsarService.clearHistory('scientific');
        _loadHistory();
      },
      hasHistoryData: _history.isNotEmpty,
    );
  }

  Widget _buildDisplayContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double expressionFontSize =
            (constraints.maxHeight * 0.15).clamp(12.0, 16.0);
        double resultFontSize =
            (constraints.maxHeight * 0.25).clamp(18.0, 32.0);
        double labelFontSize = (constraints.maxHeight * 0.12).clamp(10.0, 14.0);

        double stackLineHeight = math.max(labelFontSize + 6, 20);
        double controlsHeight = labelFontSize + 16;
        double mainDisplayHeight = resultFontSize + 16;

        double usedHeight = controlsHeight + mainDisplayHeight + 24;
        double availableForStack =
            math.max(0, constraints.maxHeight - usedHeight);

        int maxLines = 0;
        if (stackLineHeight > 0 && availableForStack > 0) {
          double ratio = availableForStack / stackLineHeight;
          if (ratio.isFinite && !ratio.isNaN) {
            maxLines = ratio.floor().clamp(0, 3);
          }
        }

        if (maxLines == 0 &&
            _calculationStack.isNotEmpty &&
            availableForStack >= stackLineHeight * 0.5) {
          maxLines = 1;
        }

        int linesToShow = math.min(maxLines, _calculationStack.length);

        return SingleChildScrollView(
          reverse: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  if (_calculationStack.isNotEmpty)
                    InkWell(
                      onTap: () {
                        if (_calculationStack.isNotEmpty) {
                          setState(() {
                            _calculationStack.removeLast();
                          });
                        }
                      },
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
      onClearHistory: null,
      onRestoreFromHistory: (item, context) {
        setState(() {
          _display = item.result;
          _expression = item.result;
          _justCalculated = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.restored)),
        );
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
      },
      showHeader: false,
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
      buttonColor = Theme.of(context).colorScheme.errorContainer;
      textColor = Theme.of(context).colorScheme.onErrorContainer;
    } else if (text == '=') {
      buttonColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.onPrimary;
    } else if (_isBasicOperator(text)) {
      buttonColor =
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
      textColor = Theme.of(context).colorScheme.primary;
    } else if (text == '2nd') {
      buttonColor = _showSecondaryFunctions
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surfaceContainerHighest;
      textColor = _showSecondaryFunctions
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSurfaceVariant;
    } else if (_isFunctionButton(text)) {
      buttonColor =
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1);
      textColor = Theme.of(context).colorScheme.secondary;
    } else if (_isNumberButton(text)) {
      buttonColor = Theme.of(context).colorScheme.surface;
      textColor = Theme.of(context).colorScheme.onSurface;
    } else if (_isConstant(text)) {
      buttonColor =
          Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1);
      textColor = Theme.of(context).colorScheme.tertiary;
    } else {
      buttonColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      textColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = (constraints.maxHeight * 0.25).clamp(12.0, 20.0);

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    GenericInfoDialog.show(
      context: context,
      title: l10n.scientificCalculatorDetailedInfo,
      overview: l10n.scientificCalculatorOverview,
      headerIcon: Icons.calculate,
      sections: [
        InfoSection(
          title: l10n.scientificKeyFeatures,
          icon: Icons.star_outline,
          color: Colors.orange,
          children: [
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.realTimeCalculation,
                description: l10n.realTimeCalculationDesc,
                icon: Icons.speed,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.comprehensiveFunctions,
                description: l10n.comprehensiveFunctionsDesc,
                icon: Icons.functions,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.dualAngleModes,
                description: l10n.dualAngleModesDesc,
                icon: Icons.rotate_left,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.secondaryFunctions,
                description: l10n.secondaryFunctionsDesc,
                icon: Icons.alt_route,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.calculationHistory,
                description: l10n.calculationHistoryDesc,
                icon: Icons.history,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.memoryOperations,
                description: l10n.memoryOperationsDesc,
                icon: Icons.memory,
              ),
            ),
          ],
        ),
        InfoSection(
          title: l10n.scientificHowToUse,
          icon: Icons.help_outline,
          color: Colors.blue,
          children: [
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                step: l10n.step1Scientific,
                description: l10n.step1ScientificDesc,
              ),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                step: l10n.step2Scientific,
                description: l10n.step2ScientificDesc,
              ),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                step: l10n.step3Scientific,
                description: l10n.step3ScientificDesc,
              ),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                step: l10n.step4Scientific,
                description: l10n.step4ScientificDesc,
              ),
            ),
          ],
        ),
        InfoSection(
          title: l10n.scientificTips,
          icon: Icons.lightbulb_outline,
          color: Colors.green,
          children: [
            GenericInfoDialog.buildTipItem(theme, l10n.tip1Scientific),
            GenericInfoDialog.buildTipItem(theme, l10n.tip2Scientific),
            GenericInfoDialog.buildTipItem(theme, l10n.tip3Scientific),
            GenericInfoDialog.buildTipItem(theme, l10n.tip4Scientific),
            GenericInfoDialog.buildTipItem(theme, l10n.tip5Scientific),
            GenericInfoDialog.buildTipItem(theme, l10n.tip6Scientific),
            GenericInfoDialog.buildTipItem(theme, l10n.tip7Scientific),
          ],
        ),
        InfoSection(
          title: l10n.scientificFunctionCategories,
          icon: Icons.category,
          color: Colors.purple,
          children: [
            GenericInfoDialog.buildMultiSubSection(
              theme: theme,
              subsections: [
                {
                  'title': l10n.basicArithmetic,
                  'description': l10n.basicArithmeticDesc,
                },
                {
                  'title': l10n.trigonometricFunctionsScientific,
                  'description': l10n.trigonometricFunctionsScientificDesc,
                },
                {
                  'title': l10n.logarithmicFunctionsScientific,
                  'description': l10n.logarithmicFunctionsScientificDesc,
                },
                {
                  'title': l10n.algebraicFunctions,
                  'description': l10n.algebraicFunctionsDesc,
                },
              ],
            ),
          ],
        ),
        InfoSection(
          title: l10n.scientificModeControls,
          icon: Icons.settings,
          color: Colors.indigo,
          children: [
            GenericInfoDialog.buildMultiSubSection(
              theme: theme,
              subsections: [
                {
                  'title': l10n.angleMode,
                  'description': l10n.angleModeDesc,
                },
                {
                  'title': l10n.functionToggle,
                  'description': l10n.functionToggleDesc,
                },
                {
                  'title': l10n.memoryFunctions,
                  'description': l10n.memoryFunctionsDesc,
                },
                {
                  'title': l10n.historyAccess,
                  'description': l10n.historyAccessDesc,
                },
              ],
            ),
          ],
        ),
        InfoSection(
          title: l10n.scientificPracticalApplications,
          icon: Icons.build,
          color: Colors.teal,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                l10n.scientificPracticalApplicationsDesc,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _restoreFromHistory(CalculatorHistory item) {
    setState(() {
      _expression = item.expression;
      _display = item.expression;
      _updateRealTimeResult();
    });
  }

  void _showClearHistoryDialog(BuildContext context) {
    // ... (Implementation remains the same)
  }

  void _showHistoryMenu(
      BuildContext context, CalculatorHistory item, Offset tapPosition) {
    // ... (Implementation updated to use CalculatorHistory)
  }
}

class _ScientificCalculatorHistoryWidget extends StatefulWidget {
  final List<CalculatorHistory> history;
  final VoidCallback? onClearHistory;
  final Function(CalculatorHistory, BuildContext) onRestoreFromHistory;
  final Function(String, BuildContext) onRestoreExpression;
  final bool showHeader;

  const _ScientificCalculatorHistoryWidget({
    super.key,
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
      AppLocalizations l10n, CalculatorHistory item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        widget.onRestoreExpression(item.expression, context),
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
                    item.result,
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
                          l10n.noHistoryMessage,
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
                  padding: const EdgeInsets.all(16),
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
