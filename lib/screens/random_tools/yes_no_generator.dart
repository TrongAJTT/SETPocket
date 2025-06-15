import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/random_generator.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/widgets/random_generator_layout.dart';

class YesNoGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const YesNoGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<YesNoGeneratorScreen> createState() => _YesNoGeneratorScreenState();
}

class _YesNoGeneratorScreenState extends State<YesNoGeneratorScreen>
    with SingleTickerProviderStateMixin {
  bool? _result;
  bool _skipAnimation = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  List<GenerationHistoryItem> _history = [];
  bool _historyEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 1,
      ),
    ]).animate(_controller);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final enabled = await GenerationHistoryService.isHistoryEnabled();
    final history = await GenerationHistoryService.getHistory('yes_no');
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

  void _generateResult() async {
    setState(() {
      _result = RandomGenerator.generateYesNo();
    });

    if (!_skipAnimation) {
      _controller.reset();
      _controller.forward();
    }

    // Save to history if enabled
    if (_historyEnabled && _result != null) {
      String resultText = _result! ? 'YES' : 'NO';
      await GenerationHistoryService.addHistoryItem(
        resultText,
        'yes_no',
      );
      await _loadHistory(); // Refresh history
    }
  }

  void _copyHistoryItem(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.copied)),
    );
  }

  Widget _buildHistoryWidget(AppLocalizations loc) {
    return RandomGeneratorHistoryWidget(
      historyType: 'yes_no',
      history: _history,
      title: loc.generationHistory,
      onClearHistory: () async {
        await GenerationHistoryService.clearHistory('yes_no');
        await _loadHistory();
      },
      onCopyItem: _copyHistoryItem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final generatorContent = Column(
      children: [
        // Skip animation option
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CheckboxListTile(
              title: Text(loc.skipAnimation),
              subtitle: Text(loc.skipAnimationDesc),
              value: _skipAnimation,
              onChanged: (value) {
                setState(() {
                  _skipAnimation = value ?? false;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Result display
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_result != null)
                  AnimatedBuilder(
                    animation: _skipAnimation
                        ? const AlwaysStoppedAnimation(1.0)
                        : _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _skipAnimation ? 1.0 : _scaleAnimation.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _result!
                                ? Colors.green.withValues(alpha: 0.8)
                                : Colors.red.withValues(alpha: 0.8),
                          ),
                          child: Center(
                            child: Text(
                              _result! ? 'YES' : 'NO',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: _generateResult,
                    icon: const Icon(Icons.help_outline),
                    label:
                        Text(_result == null ? loc.generate : loc.randomResult),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return RandomGeneratorLayout(
      generatorContent: generatorContent,
      historyWidget: _buildHistoryWidget(loc),
      historyEnabled: _historyEnabled,
      hasHistory: _history.isNotEmpty,
      isEmbedded: widget.isEmbedded,
      title: loc.yesNo,
    );
  }
}
