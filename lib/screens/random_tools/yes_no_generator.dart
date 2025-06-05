import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';
import 'package:my_multi_tools/services/generation_history_service.dart';

class YesNoGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const YesNoGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<YesNoGeneratorScreen> createState() => _YesNoGeneratorScreenState();
}

class _YesNoGeneratorScreenState extends State<YesNoGeneratorScreen>
    with SingleTickerProviderStateMixin {
  bool? _result;
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
    _controller.reset();
    _controller.forward();

    setState(() {
      _result = RandomGenerator.generateYesNo();
    });

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
    if (!_historyEnabled || _history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.generationHistory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () async {
                    await GenerationHistoryService.clearHistory('yes_no');
                    await _loadHistory();
                  },
                  child: Text(loc.clearHistory),
                ),
              ],
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
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    final generatorCard = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_result != null)
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
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
              label: Text(_result == null ? loc.generate : loc.randomResult),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final historyWidget = _buildHistoryWidget(loc);

    Widget content;
    if (isLargeScreen && (_historyEnabled && _history.isNotEmpty)) {
      // Large screen layout: generator on left, history on right
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: generatorCard,
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
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: generatorCard,
            ),
            if (_historyEnabled && _history.isNotEmpty) ...[
              const SizedBox(height: 32),
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
          title: Text(loc.yesNo),
        ),
        body: content,
      );
    }
  }
}
