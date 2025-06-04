import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';

class NumberGeneratorScreen extends StatefulWidget {
  const NumberGeneratorScreen({super.key});

  @override
  State<NumberGeneratorScreen> createState() => _NumberGeneratorScreenState();
}

class _NumberGeneratorScreenState extends State<NumberGeneratorScreen> {
  bool _isInteger = true;
  double _minValue = 1.0;
  double _maxValue = 100.0;
  int _quantity = 5;
  bool _allowDuplicates = true;
  List<num> _generatedNumbers = [];
  bool _copied = false;

  final TextEditingController _minValueController =
      TextEditingController(text: '1');
  final TextEditingController _maxValueController =
      TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _minValueController.dispose();
    _maxValueController.dispose();
    super.dispose();
  }

  void _generateNumbers() {
    try {
      // Parse values from text controllers
      double min = double.tryParse(_minValueController.text) ?? _minValue;
      double max = double.tryParse(_maxValueController.text) ?? _maxValue;

      // Ensure min is less than max
      if (min >= max) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Min must be less than max'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _minValue = min;
        _maxValue = max;
        _generatedNumbers = RandomGenerator.generateNumbers(
          isInteger: _isInteger,
          min: _minValue,
          max: _maxValue,
          count: _quantity,
          allowDuplicates: _allowDuplicates,
        );
        _copied = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyToClipboard() {
    String numbersText = _generatedNumbers.map((number) {
      if (_isInteger) {
        return number.toInt().toString();
      } else {
        return number.toStringAsFixed(2);
      }
    }).join(', ');

    Clipboard.setData(ClipboardData(text: numbersText));
    setState(() {
      _copied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
  }

  String _formatNumber(num number) {
    if (_isInteger) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(2);
    }
  }

  Widget _buildMinMaxInputs(BuildContext context, AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800; // Desktop threshold

    if (isDesktop) {
      // Desktop layout: Min and Max in same row
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _minValueController,
              decoration: InputDecoration(
                labelText: loc.minValue,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                _isInteger
                    ? FilteringTextInputFormatter.digitsOnly
                    : FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _maxValueController,
              decoration: InputDecoration(
                labelText: loc.maxValue,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                _isInteger
                    ? FilteringTextInputFormatter.digitsOnly
                    : FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),
          ),
        ],
      );
    } else {
      // Mobile layout: Min and Max in separate rows
      return Column(
        children: [
          TextField(
            controller: _minValueController,
            decoration: InputDecoration(
              labelText: loc.minValue,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              _isInteger
                  ? FilteringTextInputFormatter.digitsOnly
                  : FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maxValueController,
            decoration: InputDecoration(
              labelText: loc.maxValue,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              _isInteger
                  ? FilteringTextInputFormatter.digitsOnly
                  : FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.numberGenerator),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Number type selector
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: Text(loc.integers),
                            value: true,
                            groupValue: _isInteger,
                            onChanged: (value) {
                              setState(() {
                                _isInteger = value ?? true;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: Text(loc.floatingPoint),
                            value: false,
                            groupValue: _isInteger,
                            onChanged: (value) {
                              setState(() {
                                _isInteger = value ?? true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Min and Max value input
                    _buildMinMaxInputs(context, loc),

                    const SizedBox(height: 16),

                    // Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.quantity,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '$_quantity',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _quantity.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      label: _quantity.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _quantity = value.round();
                        });
                      },
                    ),

                    // Allow duplicates
                    CheckboxListTile(
                      title: Text(loc.allowDuplicates),
                      value: _allowDuplicates,
                      onChanged: (value) {
                        setState(() {
                          _allowDuplicates = value ?? true;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Generate button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _generateNumbers,
                        icon: const Icon(Icons.refresh),
                        label: Text(loc.generate),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Display generated numbers
            if (_generatedNumbers.isNotEmpty) ...[
              Text(
                loc.generatedNumbers,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _generatedNumbers.map((number) {
                          return Chip(
                            label: Text(_formatNumber(number)),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            labelStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _copyToClipboard,
                        icon: Icon(_copied ? Icons.check : Icons.copy),
                        label: Text(_copied ? loc.copied : loc.copyToClipboard),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
