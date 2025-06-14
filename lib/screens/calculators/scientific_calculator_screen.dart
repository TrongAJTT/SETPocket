import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'dart:math' as math;

class ScientificCalculatorScreen extends StatefulWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  State<ScientificCalculatorScreen> createState() =>
      _ScientificCalculatorScreenState();
}

class _ScientificCalculatorScreenState
    extends State<ScientificCalculatorScreen> {
  String _display = '0';
  String _expression = '';
  bool _isRadians = true;
  bool _showSecondaryFunctions = false;
  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _display = _expression.isEmpty ? '0' : _expression;
        }
      } else if (value == '=') {
        _calculate();
      } else if (value == 'Rad/Deg') {
        _isRadians = !_isRadians;
      } else if (value == '2nd') {
        _showSecondaryFunctions = !_showSecondaryFunctions;
      } else if (value == '+/-') {
        _toggleSign();
      } else if (_isSpecialFunction(value)) {
        _handleSpecialFunction(value);
      } else {
        if (_display == '0' && !_isOperator(value) && value != '.') {
          _expression = value;
        } else {
          _expression += value;
        }
        _display = _expression;
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
  }

  bool _isOperator(String value) {
    return ['+', '-', '*', '/', '^', '(', ')'].contains(value);
  }

  void _calculate() {
    try {
      String expression = _expression;

      // Handle special functions and constants
      expression = _preprocessExpression(expression);

      ShuntingYardParser parser = ShuntingYardParser();
      Expression exp = parser.parse(expression);
      ContextModel cm = ContextModel();

      double result = exp.evaluate(EvaluationType.REAL, cm);

      if (result.isNaN || result.isInfinite) {
        _display = 'Error';
        _expression = '';
      } else {
        _display = _formatResult(result);
        _expression = _display;
      }
    } catch (e) {
      _display = 'Error';
      _expression = '';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scientificCalculator),
        actions: [
          IconButton(
            icon: Icon(_isRadians
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked),
            onPressed: () => _onButtonPressed('Rad/Deg'),
            tooltip: _isRadians ? 'Radians' : 'Degrees',
          ),
        ],
      ),
      body: Column(
        children: [
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_expression.isNotEmpty && _expression != _display)
                  Text(
                    _expression,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                  ),
                Text(
                  _display,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _isRadians ? 'RAD' : 'DEG',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _showSecondaryFunctions ? '2nd' : '1st',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Buttons
          Expanded(
            child: _buildButtonGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid() {
    return GridView.count(
      crossAxisCount: 5,
      childAspectRatio: 1.2,
      padding: const EdgeInsets.all(8),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: _buildButtons(),
    );
  }

  List<Widget> _buildButtons() {
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

    List<Widget> buttons = [];

    for (int row = 0; row < buttonLayout.length; row++) {
      for (int col = 0; col < buttonLayout[row].length; col++) {
        String buttonText = buttonLayout[row][col];
        if (buttonText.isNotEmpty) {
          buttons.add(_buildButton(buttonText));
        }
      }
    }

    return buttons;
  }

  Widget _buildButton(String text) {
    Color? buttonColor;
    Color? textColor;

    if (text == 'C' || text == '⌫') {
      buttonColor = Colors.red[100];
      textColor = Colors.red[700];
    } else if (text == '=') {
      buttonColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
    } else if (_isOperator(text) || ['+', '-', '*', '/', '='].contains(text)) {
      buttonColor = Theme.of(context).primaryColor.withValues(alpha: 0.1);
      textColor = Theme.of(context).primaryColor;
    } else if (text == '2nd' && _showSecondaryFunctions) {
      buttonColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
    }

    return Card(
      elevation: 2,
      color: buttonColor,
      child: InkWell(
        onTap: () => _onButtonPressed(text),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
