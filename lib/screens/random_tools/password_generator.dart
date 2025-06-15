import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/random_generator.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/widgets/random_generator_layout.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const PasswordGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<PasswordGeneratorScreen> createState() =>
      _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  int _passwordLength = 12;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSpecial = true;
  String _generatedPassword = '';
  bool _copied = false;
  List<GenerationHistoryItem> _history = [];
  bool _historyEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final enabled = await GenerationHistoryService.isHistoryEnabled();
    final history = await GenerationHistoryService.getHistory('password');
    setState(() {
      _historyEnabled = enabled;
      _history = history;
    });
  }

  void _generatePassword() async {
    setState(() {
      try {
        _generatedPassword = RandomGenerator.generatePassword(
          length: _passwordLength,
          includeLowercase: _includeLowercase,
          includeUppercase: _includeUppercase,
          includeNumbers: _includeNumbers,
          includeSpecial: _includeSpecial,
        );
        _copied = false;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    });
    // Save to history if enabled
    if (_historyEnabled && _generatedPassword.isNotEmpty) {
      await GenerationHistoryService.addHistoryItem(
        _generatedPassword,
        'password',
      );
      await _loadHistory(); // Refresh history
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    setState(() {
      _copied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
  }

  void _copyHistoryItem(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
  }

  Widget _buildHistoryWidget(AppLocalizations loc) {
    return RandomGeneratorHistoryWidget(
      historyType: 'password',
      history: _history,
      title: loc.generationHistory,
      onClearHistory: () async {
        await GenerationHistoryService.clearHistory('password');
        await _loadHistory();
      },
      onCopyItem: _copyHistoryItem,
    );
  }

  Widget _buildCheckboxOptions(BuildContext context, AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800; // More conservative desktop threshold

    final checkboxOptions = [
      {
        'title': loc.includeLowercase,
        'value': _includeLowercase,
        'onChanged': (bool? value) {
          setState(() {
            _includeLowercase = value ?? true;
          });
        },
      },
      {
        'title': loc.includeUppercase,
        'value': _includeUppercase,
        'onChanged': (bool? value) {
          setState(() {
            _includeUppercase = value ?? true;
          });
        },
      },
      {
        'title': loc.includeNumbers,
        'value': _includeNumbers,
        'onChanged': (bool? value) {
          setState(() {
            _includeNumbers = value ?? true;
          });
        },
      },
      {
        'title': loc.includeSpecial,
        'value': _includeSpecial,
        'onChanged': (bool? value) {
          setState(() {
            _includeSpecial = value ?? true;
          });
        },
      },
    ];

    if (isDesktop) {
      // Desktop layout: 2 columns
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text(checkboxOptions[0]['title'] as String),
                  value: checkboxOptions[0]['value'] as bool,
                  onChanged:
                      checkboxOptions[0]['onChanged'] as void Function(bool?),
                  dense: true,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text(checkboxOptions[1]['title'] as String),
                  value: checkboxOptions[1]['value'] as bool,
                  onChanged:
                      checkboxOptions[1]['onChanged'] as void Function(bool?),
                  dense: true,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text(checkboxOptions[2]['title'] as String),
                  value: checkboxOptions[2]['value'] as bool,
                  onChanged:
                      checkboxOptions[2]['onChanged'] as void Function(bool?),
                  dense: true,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text(checkboxOptions[3]['title'] as String),
                  value: checkboxOptions[3]['value'] as bool,
                  onChanged:
                      checkboxOptions[3]['onChanged'] as void Function(bool?),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Mobile layout: 1 column
      return Column(
        children: checkboxOptions.map((option) {
          return CheckboxListTile(
            title: Text(option['title'] as String),
            value: option['value'] as bool,
            onChanged: option['onChanged'] as void Function(bool?),
            dense: true,
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final generatorContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Settings card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.numCharacters,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '$_passwordLength',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Slider(
                  value: _passwordLength.toDouble(),
                  min: 4,
                  max: 32,
                  divisions: 28,
                  label: _passwordLength.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _passwordLength = value.round();
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildCheckboxOptions(context, loc),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _generatePassword,
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.generate),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Result card
        if (_generatedPassword.isNotEmpty) ...[
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.generatedPassword,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectableText(
                        _generatedPassword,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
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
          ),
        ],
      ],
    );

    return RandomGeneratorLayout(
      generatorContent: generatorContent,
      historyWidget: _buildHistoryWidget(loc),
      historyEnabled: _historyEnabled,
      hasHistory: _history.isNotEmpty,
      isEmbedded: widget.isEmbedded,
      title: loc.passwordGenerator,
    );
  }
}
