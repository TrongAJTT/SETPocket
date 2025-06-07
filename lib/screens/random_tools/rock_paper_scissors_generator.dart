import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/random_generator.dart';
import 'package:my_multi_tools/services/generation_history_service.dart';

class RockPaperScissorsGeneratorScreen extends StatefulWidget {
  final bool isEmbedded;

  const RockPaperScissorsGeneratorScreen({super.key, this.isEmbedded = false});

  @override
  State<RockPaperScissorsGeneratorScreen> createState() =>
      _RockPaperScissorsGeneratorScreenState();
}

class _RockPaperScissorsGeneratorScreenState
    extends State<RockPaperScissorsGeneratorScreen>
    with SingleTickerProviderStateMixin {
  int? _result;
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
      curve: Curves.easeInOut,
    );
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final enabled = await GenerationHistoryService.isHistoryEnabled();
    final history =
        await GenerationHistoryService.getHistory('rock_paper_scissors');
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

  Future<void> _generateResult() async {
    _controller.reset();
    await _controller.forward();

    setState(() {
      _result = RandomGenerator.generateRockPaperScissors();
    }); // Save to history if enabled
    if (_historyEnabled && _result != null) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      String resultText = _getResultText(loc);
      GenerationHistoryService.addHistoryItem(
        resultText,
        'rock_paper_scissors',
      ).then((_) => _loadHistory()); // Refresh history
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
                                'rock_paper_scissors');
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
                              'rock_paper_scissors');
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

  IconData _getIcon() {
    if (_result == null) {
      return Icons.help_outline;
    }
    switch (_result) {
      case 0:
        return Icons.sports_mma; // Rock
      case 1:
        return Icons.article; // Paper
      case 2:
        return Icons.content_cut; // Scissors
      default:
        return Icons.help_outline;
    }
  }

  String _getResultText(AppLocalizations loc) {
    if (_result == null) {
      return '?';
    }
    switch (_result) {
      case 0:
        return loc.rock;
      case 1:
        return loc.paper;
      case 2:
        return loc.scissors;
      default:
        return '?';
    }
  }

  Color _getResultColor() {
    if (_result == null) {
      return Colors.grey.shade400;
    }
    switch (_result) {
      case 0:
        return Colors.brown.shade700; // Rock
      case 1:
        return Colors.blue.shade700; // Paper
      case 2:
        return Colors.red.shade700; // Scissors
      default:
        return Colors.grey.shade400;
    }
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
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + _animation.value * 0.3,
                child: Opacity(
                  opacity: 0.7 + (_animation.value * 0.3),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getResultColor().withValues(alpha: 0.2),
                      border: Border.all(
                        color: _getResultColor(),
                        width: 4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getIcon(),
                          size: 80,
                          color: _getResultColor(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getResultText(loc),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getResultColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionButton(
                  Icons.sports_mma, loc.rock, 0, Colors.brown.shade700),
              const SizedBox(width: 16),
              _buildOptionButton(
                  Icons.article, loc.paper, 1, Colors.blue.shade700),
              const SizedBox(width: 16),
              _buildOptionButton(
                  Icons.content_cut, loc.scissors, 2, Colors.red.shade700),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 50,
            child: FilledButton(
              onPressed: _generateResult,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(loc.generate),
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

    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.rockPaperScissors),
        ),
        body: content,
      );
    }
  }

  Widget _buildOptionButton(
      IconData icon, String label, int value, Color color) {
    bool isSelected = _result == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? color : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
