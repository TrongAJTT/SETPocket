import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';
import 'package:my_multi_tools/services/generation_history_service.dart';

class LatinLetterGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const LatinLetterGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<LatinLetterGeneratorScreen> createState() =>
      _LatinLetterGeneratorScreenState();
}

class _LatinLetterGeneratorScreenState extends State<LatinLetterGeneratorScreen>
    with SingleTickerProviderStateMixin {
  String _generatedLetters = '';
  int _letterCount = 10;
  double _tens = 1.0; // 0-9 representing tens place (0-90)
  double _units = 0.0; // 0-9 representing units place (0-9)
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
    // Initialize sliders based on initial _letterCount
    _updateSlidersFromCount(_letterCount);
    _generateLetters();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final enabled = await GenerationHistoryService.isHistoryEnabled();
    final history = await GenerationHistoryService.getHistory('latin_letter');
    setState(() {
      _historyEnabled = enabled;
      _history = history;
    });
  }

  void _updateSlidersFromCount(int count) {
    _tens = (count ~/ 10).toDouble();
    _units = (count % 10).toDouble();
  }

  void _updateCountFromSliders() {
    final newCount = (_tens * 10 + _units).toInt();
    // Ensure minimum of 1 letter
    final validCount = newCount == 0 ? 1 : newCount;
    if (validCount != _letterCount && validCount >= 1 && validCount <= 99) {
      setState(() {
        _letterCount = validCount;
      });
    }
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
      _generatedLetters = RandomGenerator.generateLatinLetters(_letterCount);
      _copied = false;
    });

    // Save to history if enabled
    if (_historyEnabled && _generatedLetters.isNotEmpty) {
      GenerationHistoryService.addHistoryItem(
        _generatedLetters,
        'latin_letter',
      ).then((_) => _loadHistory()); // Refresh history
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedLetters));
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
                                'latin_letter');
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
                              'latin_letter');
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
                        fontSize: 16,
                        letterSpacing: 2.0,
                      ),
                      maxLines: 3,
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

  Widget _buildSliderControls(AppLocalizations loc) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    final tensSlider = Column(
      children: [
        Text(
          loc.tens,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Slider(
          value: _tens,
          min: 0,
          max: 9,
          divisions: 9,
          label: '${_tens.toInt()}0',
          onChanged: (value) {
            setState(() {
              _tens = value;
              // If tens is 0 and units is 0, set units to 1 to maintain minimum of 1
              if (_tens == 0 && _units == 0) {
                _units = 1;
              }
            });
            _updateCountFromSliders();
          },
        ),
      ],
    );

    final unitsSlider = Column(
      children: [
        Text(
          loc.units,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Slider(
          value: _units,
          min: 0,
          max: 9,
          divisions: 9,
          label: _units.toInt().toString(),
          onChanged: (value) {
            setState(() {
              _units = value;
              // If both tens and units would be 0, set tens to 0 and units to 1
              if (_tens == 0 && value == 0) {
                _units = 1;
              } else {
                _units = value;
              }
            });
            _updateCountFromSliders();
          },
        ),
      ],
    );

    if (isWideScreen) {
      // Horizontal layout for desktop/tablet
      return Row(
        children: [
          Expanded(child: tensSlider),
          const SizedBox(width: 16),
          Expanded(child: unitsSlider),
        ],
      );
    } else {
      // Vertical layout for mobile
      return Column(
        children: [
          tensSlider,
          const SizedBox(height: 8),
          unitsSlider,
        ],
      );
    }
  }

  Widget _buildMainContent(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Configuration card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.letterCount,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Current count display
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_letterCount',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dual sliders
                _buildSliderControls(loc),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _generateLetters,
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.generate),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Result card
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
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _generatedLetters.split('').map((letter) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
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
                        _generatedLetters,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Build main content and history widgets
    final mainContent = _buildMainContent(loc);
    final historyWidget = _buildHistoryWidget(loc);

    // Responsive layout: side-by-side for large screens, vertical for small screens
    Widget content;
    if (MediaQuery.of(context).size.width >= 1200 &&
        _historyEnabled &&
        _history.isNotEmpty) {
      // Large screen: side-by-side layout
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content takes 60% of width
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: mainContent,
              ),
            ),
            const SizedBox(width: 16),
            // History takes 40% of width
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: historyWidget,
              ),
            ),
          ],
        ),
      );
    } else {
      // Small screen: vertical layout
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            mainContent,
            const SizedBox(height: 24),
            historyWidget,
          ],
        ),
      );
    }

    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.latinLetters),
        ),
        body: content,
      );
    }
  }
}
