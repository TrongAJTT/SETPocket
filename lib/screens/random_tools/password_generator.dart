import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';
import 'package:my_multi_tools/services/generation_history_service.dart';

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
    if (!_historyEnabled || _history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive header that wraps on small screens
            LayoutBuilder(
              builder: (context, constraints) {
                // If space is limited, use Column layout
                if (constraints.maxWidth < 300) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.generationHistory,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await GenerationHistoryService.clearHistory(
                                'password');
                            await _loadHistory();
                          },
                          child: Text(loc.clearHistory),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Use Row layout when there's enough space
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          loc.generationHistory,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await GenerationHistoryService.clearHistory(
                              'password');
                          await _loadHistory();
                        },
                        child: Text(loc.clearHistory),
                      ),
                    ],
                  );
                }
              },
            ),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _history.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      item.value,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${loc.generatedAt}: ${item.timestamp.toString().substring(0, 19)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () => _copyHistoryItem(item.value),
                      tooltip: loc.copyToClipboard,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    final generatorCard = Card(
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
    );

    final resultCard = _generatedPassword.isNotEmpty
        ? Column(
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
          )
        : const SizedBox.shrink();

    final historyWidget = _buildHistoryWidget(loc);

    Widget content;
    if (isLargeScreen && (_historyEnabled && _history.isNotEmpty)) {
      // Large screen layout: generator and result on left, history on right
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  generatorCard,
                  if (_generatedPassword.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    resultCard,
                  ],
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: historyWidget,
            ),
          ],
        ),
      );
    } else {
      // Small screen layout: vertical stack
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            generatorCard,
            if (_generatedPassword.isNotEmpty) ...[
              const SizedBox(height: 24),
              resultCard,
            ],
            if (_historyEnabled && _history.isNotEmpty) ...[
              const SizedBox(height: 24),
              historyWidget,
            ],
          ],
        ),
      );
    }

    // Return either the content directly (if embedded) or wrapped in a Scaffold
    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.passwordGenerator),
          elevation: 0,
        ),
        body: content,
      );
    }
  }
}
