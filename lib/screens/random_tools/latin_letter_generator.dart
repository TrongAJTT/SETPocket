import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/random_generator.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/models/random_models/random_state_models.dart';
import 'package:setpocket/services/random_services/random_state_service.dart';
import 'package:setpocket/widgets/random_generator_layout.dart';
import 'package:setpocket/widgets/quantity_selector.dart';

class LatinLetterGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const LatinLetterGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<LatinLetterGeneratorScreen> createState() =>
      _LatinLetterGeneratorScreenState();
}

class _LatinLetterGeneratorScreenState extends State<LatinLetterGeneratorScreen>
    with SingleTickerProviderStateMixin {
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  int _letterCount = 5;
  bool _allowDuplicates = true;
  List<String> _generatedLetters = [];
  bool _copied = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<GenerationHistoryItem> _history = [];
  bool _historyEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _loadState();
    _loadHistory();
  }

  Future<void> _loadState() async {
    try {
      final state = await RandomStateService.getLatinLetterGeneratorState();
      if (mounted) {
        setState(() {
          _includeUppercase = state.includeUppercase;
          _includeLowercase = state.includeLowercase;
          _letterCount = state.letterCount;
          _allowDuplicates = state.allowDuplicates;
        });
      }
    } catch (e) {
      // Error is already logged in service
    }
  }

  Future<void> _saveState() async {
    try {
      final state = LatinLetterGeneratorState(
        includeUppercase: _includeUppercase,
        includeLowercase: _includeLowercase,
        letterCount: _letterCount,
        allowDuplicates: _allowDuplicates,
        lastUpdated: DateTime.now(),
      );
      await RandomStateService.saveLatinLetterGeneratorState(state);
    } catch (e) {
      // Error is already logged in service
    }
  }

  Future<void> _loadHistory() async {
    final enabled = await GenerationHistoryService.isHistoryEnabled();
    final history = await GenerationHistoryService.getHistory('latin_letter');
    setState(() {
      _historyEnabled = enabled;
      _history = history;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateLetters() {
    _controller.reset();
    _controller.forward();

    setState(() {
      final lettersString = RandomGenerator.generateLatinLetters(
        _letterCount,
        includeUppercase: _includeUppercase,
        includeLowercase: _includeLowercase,
        allowDuplicates: _allowDuplicates,
      );
      _generatedLetters = lettersString.split('');
      _copied = false;
    });

    // Save to history if enabled
    if (_historyEnabled && _generatedLetters.isNotEmpty) {
      GenerationHistoryService.addHistoryItem(
        _generatedLetters.join(''),
        'latin_letter',
      ).then((_) => _loadHistory()); // Refresh history
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedLetters.join('')));
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
      historyType: 'latin_letter',
      history: _history,
      title: loc.generationHistory,
      onClearHistory: () async {
        await GenerationHistoryService.clearHistory('latin_letter');
        await _loadHistory();
      },
      onCopyItem: _copyHistoryItem,
    );
  }

  Widget _buildQuantitySelector(AppLocalizations loc) {
    return Center(
      child: QuantitySelector(
        value: _letterCount,
        minValue: 1,
        maxValue: 99,
        smallStep: 1,
        largeStep: 10,
        label: loc.letterCount,
        onChanged: (newValue) {
          setState(() {
            _letterCount = newValue;
          });
          _saveState();
        },
        showBorder: false,
        highlightValue: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final generatorContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quantity selector - moved to top and centered
        _buildQuantitySelector(loc),
        const SizedBox(height: 24),

        // Options card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.options,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: Text(loc.includeUppercase),
                  value: _includeUppercase,
                  onChanged: (value) {
                    setState(() {
                      _includeUppercase = value ?? true;
                    });
                    _saveState();
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Text(loc.includeLowercase),
                  value: _includeLowercase,
                  onChanged: (value) {
                    setState(() {
                      _includeLowercase = value ?? true;
                    });
                    _saveState();
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Text(loc.allowDuplicates),
                  value: _allowDuplicates,
                  onChanged: (value) {
                    setState(() {
                      _allowDuplicates = value ?? true;
                    });
                    _saveState();
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Generate button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _generateLetters,
            icon: const Icon(Icons.refresh),
            label: Text(loc.generate),
          ),
        ),

        const SizedBox(height: 24),

        // Result card
        if (_generatedLetters.isNotEmpty) ...[
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.9 + (_animation.value * 0.1),
                child: child,
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.randomResult,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: Icon(_copied ? Icons.check : Icons.copy),
                          onPressed: _copyToClipboard,
                          tooltip: loc.copyToClipboard,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _generatedLetters.map((letter) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText(
                          _generatedLetters.join(''),
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );

    return RandomGeneratorLayout(
      generatorContent: generatorContent,
      historyWidget: _buildHistoryWidget(loc),
      historyEnabled: _historyEnabled,
      hasHistory: _historyEnabled,
      isEmbedded: widget.isEmbedded,
      title: loc.latinLetters,
    );
  }
}
